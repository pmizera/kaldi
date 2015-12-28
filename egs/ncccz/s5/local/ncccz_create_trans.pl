#!/usr/bin/perl
# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0

use locale;

@ARGV == 1 ||  die "usage: ncccz_create_trans.pl <train-list>";
$train_list = $ARGV[0];
$uppercase=0;

use lib "local";
use phones_conv;

@list_sound =`cat $train_list`;
for $line (@list_sound){
 chomp($line);
 pop(@pole);
 push(@pole,"$line");
 ($a,$b,$c) = $line =~ /(\d*_)(\w*_)(.*)/;
 chop($a);chop($b);$new_spk=$a."_".$b;
 $n_ses=sprintf("%02d",$a);
 $set_path = "/data/NCCCz/SHORT-CONCAT/SES$n_ses/$line";
 $path_sig = "$set_path.iso";
 $line_EPI=`cat $path_sig`;
 chomp($line_EPI);
 $line_EPI =~ s/\[[^][]*]//g;
 $line_EPI =~ s/^\s+|\s+$//g;
 $line_EPI =~ s/\ {2,}/ /g;
 $line_EPI =~ s/\[[^][]*]\s?//g;
 $line_EPI =~ s/\?|\,|\.|\*|\~//g;
 if($line_EPI eq ''){
  next;
 }
 if ($uppercase) {
   $line_EPI = uc($line_EPI);
 } else {
   $line_EPI = lc($line_EPI);
 }
 @line_EPI_sym = split(/ /,$line_EPI);
 foreach $text(@line_EPI_sym){
        $text =~ s/\ {2,}/ /g;
        push(@pole,"$text");
 }
 print"@pole";
 print "\n";
 @pole = undef;
}
