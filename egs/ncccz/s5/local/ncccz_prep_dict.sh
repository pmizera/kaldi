#!/bin/bash

# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0
# Note: This file is based on wsj/s5/local/wsj_prepare_dict.sh

# The parts of the output of this that will be needed are
# [in data/local/dict/ ]
# lexicon.txt
# extra_questions.txt
# nonsilence_phones.txt
# optional_silence.txt
# silence_phones.txt

# run this from ../

dict_suffix=""
dict_path=conf/ncccz/ncccz_sorted.dict

. ./utils/parse_options.sh

dir_work=`pwd`
srcdir=$dir_work/data/train
dir=$dir_work/data/local/dict${dict_suffix}

mkdir -p $dir

[ -f path.sh ] && . ./path.sh

# Dictionary preparation:
  # silence phones, one per line.
  export LANG=cs_CZ.iso-8859-2
  export LANGUAGE=cs
  export LC_ALL=cs_CZ.iso-8859-2
  sed "s/\t/ /" $dict_path | tr "[:upper:]" "[:lower:]" > $dir/lexicon.txt
  export LC_ALL=C

  echo sil > $dir/silence_phones.txt
  echo sil > $dir/optional_silence.txt
  cut -f2- -d' ' $dir/lexicon.txt | tr ' ' '\n'  | sort -u > $dir/phones.txt
  echo "!sil sil" >> $dir/lexicon.txt
  sort -u -o $dir/lexicon.txt $dir/lexicon.txt
  grep -v -F -f $dir/silence_phones.txt $dir/phones.txt > $dir/nonsilence_phones.txt
  touch $dir/extra_questions.txt

echo "Dictionary preparation succeeded"
