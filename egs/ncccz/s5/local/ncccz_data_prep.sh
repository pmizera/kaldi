#!/bin/bash

# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0

# Usage:
#       bash ncccz_data_prep.sh $dir_work /data/NCCCz ctucopy lang_prep/local 80_20

min_words=13;
max_words=17;
test_sets="80_20"
tool="compute-mfcc"

. ./path.sh
. ./utils/parse_options.sh

if [ $# -le 1 ]; then
   echo "Arguments should be a list of database directories, see ../run.sh for example."
   exit 1;
fi

database=$1;shift
dir_work=`pwd`

dir=$dir_work/data/local/data/ncccz_$test_sets
dir_tmp=$dir/tmp
mkdir -p $dir $dir_tmp $dir/test
local=`pwd`/local

isofile=conf/ncccz/corpusFile3pp_concat.iso

  # spk2gender
  sort -u -k1 conf/ncccz/spk2gender > $dir/test/spk2gender
  grep 'm' $dir/test/spk2gender > $dir_tmp/spk_m
  grep 'f' $dir/test/spk2gender > $dir_tmp/spk_f
  paste -d '\n' $dir_tmp/spk_m $dir_tmp/spk_f | cut -f1 -d' ' > $dir_tmp/spk

  # train/test set
  case $test_sets in
     all)
         cp $dir_tmp/spk $dir_tmp/spk_test
         cp $dir_tmp/spk $dir_tmp/spk_train
         echo "set all"
      ;;
     80_20)
         echo "set 80 x 20"
         head -n 20 $dir_tmp/spk > $dir_tmp/spk_test
         tail -n 40 $dir_tmp/spk > $dir_tmp/spk_train
      ;;
     90_10)
         echo "set 90 x 10"
         head -n 10 $dir_tmp/spk > $dir_tmp/spk_test
         tail -n 50 $dir_tmp/spk > $dir_tmp/spk_train
      ;;
  esac

 cut -f1 -d' ' $isofile | sed -e "s/^5_/05_/" -e "s/^6_/06_/" -e "s/^7_/07_/" -e "s/^9_/09_/" > $dir_tmp/list_wav
 grep -f $dir_tmp/spk_train $dir_tmp/list_wav > $dir_tmp/list_train_wav
 grep -f $dir_tmp/spk_test  $dir_tmp/list_wav > $dir_tmp/list_test_wav

 # Create: - list for test and train LM
 #         - list skp2utt utt2spk
 for x in test train;do
    mkdir -p $dir/$x
    local/ncccz_create_list.pl  $dir_tmp/list_${x}_wav wav $dir/$x/wav.scp $tool
    export LANG=cs_CZ.iso-8859-2
    export LANGUAGE=cs
    export LC_ALL=cs_CZ.iso-8859-2
    local/ncccz_create_trans.pl $dir_tmp/list_${x}_wav > $dir_tmp/trans_$x
    #clean trans
    cat $dir_tmp/trans_$x | grep -v '(' | grep -v "\&amp" | grep -v "\\$" | grep -v ";"> $dir/$x/text
    export LC_ALL=C
    utils/filter_scp.pl $dir/$x/spk2utt conf/ncccz/spk2gender > $dir/$x/spk2gender
 done

 #list for test range 13-17 words
 while read i;do
   num_w=$((`echo -n "$i" | wc -w`-1)); if [ $num_w -ge $min_words ] && [ $num_w -le $max_words ]; then echo $num_w "$i";fi ;
 done<$dir/test/text  > $dir_tmp/list_test_num_w_${min_words}_${max_words}_text
 cut -f2- -d' ' $dir_tmp/list_test_num_w_${min_words}_${max_words}_text > $dir_tmp/list_test_${min_words}_${max_words}_text_fix

 testfix=$dir/test_${min_words}_${max_words}
 mkdir -p $testfix
 for x in text utt2spk wav.scp;do
     utils/filter_scp.pl $dir_tmp/list_test_${min_words}_${max_words}_text_fix $dir/test/$x > $testfix/$x
 done
 utils/utt2spk_to_spk2utt.pl $testfix/utt2spk > $testfix/spk2utt
 utils/filter_scp.pl $testfix/spk2utt $dir/test/spk2gender > $testfix/spk2gender

 ln -s $dir/train $dir_work/data/
 ln -s $dir/test  $dir_work/data/
 ln -s $dir/test_${min_words}_${max_words} $dir_work/data/

echo "NCCCz Data preparation succeeded"


