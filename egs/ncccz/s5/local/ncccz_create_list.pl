#!/usr/bin/perl
# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Mizera)
# Apache 2.0

$input_list  = $ARGV[0] ;
$channel     = $ARGV[1] ;
$target_list = $ARGV[2] ;
$tool        = $ARGV[3] ;

if ( $input_list  eq "" ){die "Type of input_list list must be specified!\n"};
if ( $channel     eq "" ){die "Type of channel \"CS0\" must be specified!\n"};
if ( $target_list eq "" ){die "Type of target_list must be specified!\n"};

$utt_f = $target_list;
$spk_f = $target_list;
$utt_f =~ s/wav\.scp/utt2spk/;
$spk_f =~ s/wav\.scp/spk2utt/;

open LISTs, "$input_list"   or die "Cannot open $input_list !\n" ;
open OUT,   ">$target_list" or die "Cannot open $target_list for writing!\n" ;
open SPK,   ">$spk_f"       or die "Cannot open $spk_f for writing!\n" ;
open UTT,   ">$utt_f"       or die "Cannot open $utt_f for writing!\n" ;
@all_LISTs = <LISTs> ;
close LISTs;

$spk_id="";
@spk="";
for $line (@all_LISTs){
 chomp($line); 
 ($a,$b,$c) = $line =~ /(\d*_)(\w*_)(.*)/;
 chop($a);chop($b);$new_spk=$a."_".$b;
 $n_ses=sprintf("%02d",$a);
 $set_path = "/data/NCCCz/SHORT-CONCAT/SES$n_ses/$line";

  printf OUT "$line $set_path.$channel\n";
 if($spk_id ne "$new_spk" & $spk_id ne ""){
    print SPK "$spk_id @spk\n";
    @spk  = undef;
 }
 $spk_id=$a."_".$b;
 push(@spk,"$line");
 print UTT "$line $spk_id\n";
}
print SPK "$spk_id @spk\n";
close OUT;
close UTT;
close SPK;
