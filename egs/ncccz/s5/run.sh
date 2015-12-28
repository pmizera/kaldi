#!/bin/bash

# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0
# The example script for the NCCCz database.
# http://www.mirjamernestus.nl/Ernestus/NCCCz/

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

# This is a shell script, but it's recommended that you run the commands one by
# one by copying and pasting into the shell.

[ -f path.sh ] && . ./path.sh
set -e

# AM config file if exists
[ -f conf/am-conf.sh ] && . ./conf/am-conf.sh

ncccz=/data/NCCCz/SHORT-CONCAT

# Feature extraction config file
param="mfcc.conf"

stage=$1;
nameLM="lm_tg"

# "nosp" refers to the dictionary before silence probabilities and pronunciation
# probabilities are added.
dict_suffix="_nosp"

if [ $stage == 0 ]; then
   echo "Data & Lexicon & Language Preparation"
   local/ncccz_data_prep.sh $ncccz || exit 1;
   local/ncccz_prep_dict.sh --dict-suffix "$dict_suffix"
   utils/prepare_lang.sh --position-dependent-phones false --num-sil-states 3 data/local/dict${dict_suffix} "!sil" \
                              data/local/lang_tmp${dict_suffix} data/lang${dict_suffix} || exit 1;
   local/create_LM.sh --order "3" --smoothing "-kndiscount" --interpolate "-no" --nameLM "$nameLM" data/train/text data/local/lm/words/$nameLM || exit 1;
   local/ncccz_format_local_lms.sh --lang-suffix "$dict_suffix" --nameLM "$nameLM" --lm-srcdir "data/local/lm/words/$nameLM" data/lang
fi

if [ $stage == 1 ]; then
   echo "Feature Extration & CMVN for Training and Test set"
   data_dir=mfcc
   for x in train test; do
     utils/fix_data_dir.sh data/$x
     steps/make_mfcc.sh --mfcc-config conf/$param --cmd "$train_cmd" --nj 10 data/$x exp/$param/$x $data_dir/$param || exit 1;
     steps/compute_cmvn_stats.sh data/$x exp/$param/$x $data_dir/$param || exit 1;
   done
fi

if [ $stage == 2 ]; then
   echo "MonoPhone Training & Decoding"
   steps/train_mono.sh  --nj "$train_nj" --cmd "$train_big_memory_cmd" data/train data/lang$dict_suffix exp/mono || exit 1;

   echo "tri1 : Deltas + Delta-Deltas Training & Decoding"
   steps/align_si.sh --boost-silence 1.25 --nj "$train_nj" --cmd "$train_cmd" data/train data/lang$dict_suffix exp/mono exp/mono_ali || exit 1;
   steps/train_deltas.sh --cmd "$train_cmd" $numLeavesTri1 $numGaussTri1 data/train data/lang$dict_suffix exp/mono_ali exp/tri1 || exit 1;

   echo "tri2 : LDA + MLLT Training & Decoding"
   steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" data/train data/lang$dict_suffix exp/tri1 exp/tri1_ali || exit 1;
   steps/train_lda_mllt.sh --cmd "$train_cmd" --splice-opts "--left-context=5 --right-context=5" $numLeavesMLLT $numGaussMLLT data/train data/lang$dict_suffix exp/tri1_ali exp/tri2 || exit 1;

   echo "tri3 : LDA + MLLT + SAT Training & Decoding"
   steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" --use-graphs true data/train data/lang$dict_suffix exp/tri2 exp/tri2_ali || exit 1;
   steps/train_sat.sh --cmd "$train_cmd" $numLeavesSAT $numGaussSAT data/train data/lang$dict_suffix exp/tri2_ali exp/tri3 || exit 1;

   echo "SGMM2 Training & Decoding"
   steps/align_fmllr.sh --nj "$train_nj" --cmd "$train_cmd" data/train data/lang$dict_suffix exp/tri3 exp/tri3_ali || exit 1;
   steps/train_ubm.sh --cmd "$train_cmd" $numGaussUBM data/train data/lang$dict_suffix exp/tri3_ali exp/ubm4 || exit 1;
   steps/train_sgmm2.sh --cmd "$train_cmd" $numLeavesSGMM $numGaussSGMM data/train data/lang$dict_suffix exp/tri3_ali exp/ubm4/final.ubm exp/sgmm2_4 || exit 1;

   echo "SGMM2 Training & Decoding"
   steps/align_fmllr.sh --nj "$train_nj" --cmd "$train_cmd" data/train data/lang$dict_suffix exp/tri3 exp/tri3_ali || exit 1;
   steps/train_ubm.sh --cmd "$train_cmd" $numGaussUBM data/train data/lang$dict_suffix exp/tri3_ali exp/ubm4 || exit 1;
   steps/train_sgmm2.sh --cmd "$train_cmd" $numLeavesSGMM $numGaussSGMM data/train data/lang$dict_suffix exp/tri3_ali exp/ubm4/final.ubm exp/sgmm2_4 || exit 1;

   echo "MMI + SGMM2 Training & Decoding"
   steps/align_sgmm2.sh --nj "$train_nj" --cmd "$train_cmd" --transform-dir exp/tri3_ali --use-graphs true --use-gselect true \
                        data/train data/lang$dict_suffix exp/sgmm2_4 exp/sgmm2_4_ali || exit 1;

   steps/make_denlats_sgmm2.sh --nj "$train_nj" --sub-split "$train_nj" --acwt 0.2 --lattice-beam 10.0 --beam 18.0 --cmd "$train_big_memory_cmd" \
                        --transform-dir exp/tri3_ali \
                        data/train data/lang$dict_suffix exp/sgmm2_4_ali exp/sgmm2_4_denlats || exit 1;

   steps/train_mmi_sgmm2.sh --acwt 0.2 --cmd "$decode_cmd" --transform-dir exp/tri3_ali --boost 0.1 --drop-frames true \
                        data/train data/lang$dict_suffix exp/sgmm2_4_ali exp/sgmm2_4_denlats exp/sgmm2_4_mmi_b0.1 || exit 1;
fi

if [ $stage == 3 ]; then
   echo "Create HCLG.fst graphs"
   for lm in $nameLMphn $nameLM; do
      (
       $big_memory_cmd JOB=1:1 exp/mono/log/mkgraph.$lm.log \
       utils/mkgraph.sh --mono data/lang_test_$lm exp/mono exp/mono/graph_test_$lm || exit 1;
      )&
      for x in tri1 tri2 tri3 sgmm2_4; do
         (
         $big_memory_cmd JOB=1:1 exp/$x/log/mkgraph.$lm.log \
         utils/mkgraph.sh data/lang_test_$lm exp/$x exp/$x/graph_test_$lm || exit 1;
         )&
      done
   done
   wait
fi

if [ $stage == 4 ]; then
   echo "Decode"
   for lm in $nameLMphn $nameLM; do
    for test in test; do
      (
      steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" exp/mono/graph_test_$lm \
                     data/$test exp/mono/decode_${test}_$lm || exit 1;

      steps/decode.sh --stage 10 --nj "$decode_nj" --cmd "$decode_cmd" \
                      exp/tri2/graph_test_$lm data/$test exp/tri2/decode_${test}_$lm || exit 1;

      steps/decode_fmllr.sh --stage 10 --nj "$decode_nj" --cmd "$decode_cmd" \
                      exp/tri3/graph_test_$lm data/$test exp/tri3/decode_${test}_$lm || exit 1;

      steps/decode_sgmm2.sh --stage 10 --nj "$decode_nj" --cmd "$decode_cmd" --transform-dir exp/tri3/decode_${test}_$lm \
                      exp/sgmm2_4/graph_test_$lm data/$test exp/sgmm2_4/decode_${test}_$lm || exit 1;

      for iter in 1 2 3 4; do
        (
        steps/decode_sgmm2_rescore.sh --cmd "$decode_cmd" --iter $iter --transform-dir exp/tri3/decode_${test}_$lm data/lang_test_$lm \
                      data/$test exp/sgmm2_4/decode_${test}_$lm exp/sgmm2_4_mmi_b0.1/decode_${test}_${lm}_it$iter || exit 1;
         )&
      done
      )&
    done # test set
   done  # lms
fi
