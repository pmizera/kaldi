#!/usr/bin/perl
# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0

use lib "local/";
use phones_conv;
use Getopt::Long;
use Unicode::Normalize;
use open ':encoding(iso-8859-2)';
binmode(STDOUT, ":encoding(iso-8859-2)");

@ARGV == 1 ||  die "usage: ncccz_norm_dict.pl <dict>";
$in  = $ARGV[0];
$uppercase=0;

open DICT, "$in" or die "Cannot open $in !\n" ;

for $line (<DICT>){
 chomp($line);
 ($word,$frequency,@pronunciation) = split(/\t/,$line);
 if ($uppercase) {
   $word = uc($word);
 } else {
   $word = lc($word);
 }
 foreach $l(@pronunciation){
         $l =~ s/ //g;
         $l = &desampify ($l);
         $pron = &ipactu2htk ($l);
         print "$word $pron\n";
 }
}
