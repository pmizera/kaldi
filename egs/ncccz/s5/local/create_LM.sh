#!/bin/bash

# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0

. ./cmd.sh
. ./path.sh

cmd="run.pl"

# Setup of LMs -----------------------------------------------------------------------------------------
order='2'                # order of created LM '2' '3'
smoothing='-kndiscount'  # smoothing '-kndiscount' '-wbdiscount' '-gtdiscount' without specifying default is Good-Turing
interpolate='-no'        # '-yes', '-no'

#settings for minimal count of ngrams that will appear in created LM e.g. '-gt2min3' will result in
#excluding 2grams with count lower than 3 from LM defaultly ngrams of order >=3 will be omitted if their
#count is lower than 2 '-gt1min 1 -gt2min 1 -gt3min 1'
gtmin='-gt1min 1 -gt2min 1 -gt3min 1'
nameLM="lm_order_${order}_smoothing${smoothing}_interpolate${interpolate}_gtmin${gtminname}"
#-------------------------------------------------------------------------------------------------------

. ./utils/parse_options.sh

input_text=$1     # data/local/train/text
dir=$2            # data/local/lm

gtminname=`echo $gtmin | sed -e "s/ /-/g" -e "s/--/-/g"`

mkdir -p $dir
export LC_ALL=C

(
echo "input_text: $input_text"
echo "order: $order"
echo "gtmin: $gtmin"
echo "smoothing: $smoothing"
echo "interpolate: $interpolate"
) > $dir/$nameLM.setup

interpolatem=$interpolate;
[ $smoothing == "-goodturing" ] && smoothing="";
[ $interpolatem == "-no" ] && interpolate="";
[ $interpolatem == "-yes" ] && interpolate='-interpolate';

cut -f2- -d' ' $input_text | sed -e "s/^/<s> /" -e "s/$/ <\/s>/" > ${input_text}.lm

$SRILM/ngram-count -text ${input_text}.lm -sort -order $order $gtmin $smoothing $interpolate -debug 1 -lm $dir/$nameLM.gz 2>$dir/$nameLM.log

echo "ngram-count -text $input_text -sort -order $order $gtmin $smoothing $interpolate -debug 1 -lm $dir/$nameLM.gz" >> $dir/$nameLM.setup
echo "LM was created: $dir"
