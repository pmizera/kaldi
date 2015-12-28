#!/bin/bash

# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0
# Create acoustic features using the ctucopy4 tool
# Note: This file is based on make_mfcc.sh

# Begin configuration section.
nj=4
cmd=run.pl
fea_config=conf/ctucopy.conf
compress=true
tool=ctucopy4
# End configuration section.

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# != 3 ]; then
   echo "Usage: $0 [options] <data-dir> <log-dir> <path-to-feadir>";
   echo "e.g.: $0 data/train exp/make_fea/train fea"
   echo "options: "
   echo "  --ctucopy_config <config-file>                   # config passed to ctucopy4"
   echo "  --nj <nj>                                        # number of parallel jobs"
   echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
   echo "  --compress <true/false>                          # compression of features"
   exit 1;
fi

data=$1
logdir=$2
feadir=$3

# make $feadir an absolute pathname.
feadir=`perl -e '($dir,$pwd)= @ARGV; if($dir!~m:^/:) { $dir = "$pwd/$dir"; } print $dir; ' $feadir ${PWD}`

# use "name" as part of name of the archive.
name=`basename $data`

mkdir -p $feadir || exit 1;
mkdir -p $logdir || exit 1;

if [ -f $data/feats.scp ]; then
  mkdir -p $data/.backup
  echo "$0: moving $data/feats.scp to $data/.backup"
  mv $data/feats.scp $data/.backup
fi

if [ -z $CTUCOPY ] ; then
  export CTUCOPY=$KALDI_ROOT/tools/extras/ctucopy/CtuCopy_4.0.0/Default
fi

export PATH=${PATH}:$CTUCOPY
if ! command -v $tool >/dev/null 2>&1 ; then
  echo "$0: Error: the Ctucopy is not available or compiled" >&2
  echo "$0: Error: To install it, go to $KALDI_ROOT/tools" >&2
  echo "$0: Error: and run extras/install_ctucopy.sh" >&2
  exit 1
fi

scp=$data/wav.scp

cat $scp | awk '{print $2, $1}' > $data/wav_ctucopy.scp
scp=$data/wav_ctucopy.scp

required="$scp $config"

for f in $required; do
  if [ ! -f $f ]; then
    echo "make_fea_ctucopy.sh: no such file $f"
    exit 1;
  fi
done
utils/validate_data_dir.sh --no-text --no-feats $data || exit 1;

for n in $(seq $nj); do
  # the next command does nothing unless $feadir/storage/ exists, see
  # utils/create_data_link.pl for more info.
    utils/create_data_link.pl $feadir/fea_$name.$n.ark
done

  split_scps=""
  for n in $(seq $nj); do
    split_scps="$split_scps $logdir/wav_${name}.$n.scp"
  done

  utils/split_scp.pl $scp $split_scps || exit 1;

  if [ $compress != "true" ]; then
    $cmd JOB=1:$nj $logdir/make_fea_${name}.JOB.log $tool -C $fea_config -S $logdir/wav_${name}.JOB.scp -format_out ark=$feadir/fea_$name.JOB.ark || exit 1;
  else
    $cmd JOB=1:$nj $logdir/make_fea_${name}.JOB.log $tool -C $fea_config -S $logdir/wav_${name}.JOB.scp -format_out ark=$feadir/fea_ctucopy_$name.JOB.ark || exit 1;
    $cmd JOB=1:$nj $logdir/compress${name}.JOB.log  copy-feats --compress ark:$feadir/fea_ctucopy_$name.JOB.ark ark,scp:$feadir/fea_$name.JOB.ark,$feadir/fea_$name.JOB.scp || exit 1;
    rm $feadir/*ctucopy*
  fi

if [ -f $logdir/.error.$name ]; then
  echo "Error producing $name features for $name:"
  tail $logdir/make_fea_${name}.1.log
  exit 1;
fi

# concatenate the .scp files together.
for n in $(seq $nj); do
  cat $feadir/fea_$name.$n.scp || exit 1;
done > $data/feats.scp

rm $logdir/wav_${name}.*.scp 2>/dev/null

nf=`cat $data/feats.scp | wc -l`
nu=`cat $data/utt2spk | wc -l`
if [ $nf -ne $nu ]; then
  echo "It seems not all of the feature files were successfully processed ($nf != $nu);"
  echo "consider using utils/fix_data_dir.sh $data"
fi

if [ $nf -lt $[$nu - ($nu/20)] ]; then
  echo "Less than 95% the features were successfully generated.  Probably a serious error."
  exit 1;
fi

echo "Succeeded creating features for $name"
