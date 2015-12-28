#!/bin/bash

# Copyright Johns Hopkins University (Author: Daniel Povey) 2012
#           Guoguo Chen 2014
#           2015  CTU in Prague (modification: Petr Mizera)
# Apache 2.0

lang_suffix=
lm_srcdir=
nameLM=

echo "$0 $@"  # Print the command line for logging
. ./path.sh
. utils/parse_options.sh || exit 1;

lang=$1 # data/lang

[ ! -d $dir ] && echo "Expect $dir to exist" && exit 1;

[ ! -d "$lm_srcdir" ] && echo "No such dir $lm_srcdir" && exit 1;

for d in ${lang}_test_$nameLM; do
  rm -r $d 2>/dev/null
  cp -r ${lang}$lang_suffix $d
done

# Check a few files that we have to use.
for f in words.txt oov.int; do
  if [[ ! -f ${lang}$lang_suffix/$f ]]; then
    echo "$0: no such file $lang/$f"
    exit 1;
  fi
done

# Parameters needed for ConstArpaLm.
unk=`cat ${lang}$lang_suffix/oov.int`
bos=`grep "<s>" ${lang}$lang_suffix/words.txt | awk '{print $2}'`
eos=`grep "</s>" ${lang}$lang_suffix/words.txt | awk '{print $2}'`
if [[ -z $bos || -z $eos ]]; then
  echo "$0: <s> and </s> symbols are not in $lang/words.txt"
  exit 1;
fi
   mkdir -p ${lang}$lang_suffix/tmp
   gunzip -c $lm_srcdir/$nameLM.gz | utils/find_arpa_oovs.pl ${lang}$lang_suffix/words.txt > ${lang}$lang_suffix/tmp/oovs_$nameLM.txt
   echo ${lang}$lang_suffix/tmp/oovs_$nameLM.txt

   # Removing all "illegal" combinations of <s> and </s>, which are supposed to
   # occur only at being/end of utt.  These can cause determinization failures
   # of CLG [ends up being epsilon cycles].

   gunzip -c $lm_srcdir/$nameLM.gz | \
     grep -v '<s> <s>' | \
     grep -v '</s> <s>' | \
     grep -v '</s> </s>' | \
     arpa2fst - | fstprint | \
     utils/remove_oovs.pl ${lang}$lang_suffix/tmp/oovs_$nameLM.txt | \
     utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=${lang}$lang_suffix/words.txt \
                --osymbols=${lang}$lang_suffix/words.txt \
                --keep_isymbols=false \
                --keep_osymbols=false \
   | fstrmepsilon > ${lang}_test_$nameLM/G.fst || exit 1;
   fstisstochastic ${lang}_test_$nameLM/G.fst
exit 0;
