#!/usr/bin/perl
###############
# Copyright 2015 SpeechLab at FEE CTU Prague (Author: Petr Pollak, Petr Mizera, SpeechLab members at FEE CTU Prague)
# Apache 2.0

#########################################################
#
#  Knihovna pro konverzi fonetickych abeced
#
#########################################################

use locale ;


# Prolozeni retezce znaku mezerami
##################################################################

sub insert_spaces {

    ( $input ) = @_ ;
    local ( $output, $i, $line_len, $char ) ;


    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
	$char = substr ( $input, $i, 1 ) ;
	$output = "$output$char " ;
    }
    $output =~ s/ +$//g ;

    return ( $output ) ;

}

# Konverze mezi fonet. abecedami IPA CTU (nase) a Czech SAMPA
##################################################################

sub sampify {

    ($input) = @_ ;
    local ( $output, %sampify, $i, $line_len, $char ) ;

    %sampify = (
		"e" => "e",
		"o" => "o",
		"a" => "a",
		"y" => "i",
		"t" => "t",
		"s" => "s",
		"n" => "n",
		"l" => "l",
		"r" => "r",
		"ý" => "i:",
		"k" => "k",
		"v" => "v",
		"p" => "p",
		"m" => "m",
		"d" => "d",
		"j" => "j",
		"u" => "u",
		"ò" => "J",
		"á" => "a:",
		"z" => "z",
		"c" => "t_s",
		"b" => "b",
		"h" => "h\\",
		"ø" => "P\\",
		"Ø" => "Q\\",
		"é" => "e:", 
		"¹" => "S", 
		"f" => "f", 
		"è" => "t_S",
		"H" => "x", 
		"»" => "c", 
		"¾" => "Z", 
		"ú" => "u:", 
		"O" => "o_u",
		"ï" => "J\\",
		"g" => "g",
		"N" => "N",
		"A" => "a_u",
		"ó" => "o:",
		"E" => "e_u",
		"Z" => "d_z",
		"M" => "F",
		"®" => "d_Z",
		" " => " ",
		"ä" => "E:",
		"ö" => "2:",
		"ü" => "y:",
		"?" => "?",
		"@" => "@",
		"|" => "|",
		"*" => "*",
		"~" => "~",
		"%" => "%",
		"1" => " ",
		"0" => " ",
		);

    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
	$char = substr ( $input, $i, 1 ) ;
	if ( $char eq "[" ) {
	    while ( $char ne "]" ) {
		$output = "$output$char" ;
		$i++ ;
		$char = substr ( $input, $i, 1 ) ;
	    }
	    $output = "$output$char" ;
	}
	else {
	    $output = "$output$sampify{$char}" ;
	}
    }

    return ( $output ) ;

}

sub desampify {

    ($input) = @_ ;
    local ( $output, %desampify, $i, $line_len, $char, $char2 ) ;

    %desampify = (
		  "e" => "e",
		  "o" => "o",
		  "a" => "a",
		  "i" => "y",
		  "t" => "t",
		  "s" => "s",
		  "n" => "n",
		  "l" => "l",
		  "r" => "r",
		  "i:" => "ý",
		  "k" => "k",
		  "v" => "v",
		  "p" => "p",
		  "m" => "m",
		  "d" => "d",
		  "j" => "j",
		  "u" => "u",
		  "J" => "ò",
		  "a:" => "á",
		  "z" => "z",
		  "t_s" => "c",
		  "b" => "b",
		  "h\\" => "h",
		  "P\\" => "ø",
		  "Q\\" => "Ø",
		  "e:" => "é",
		  "S" => "¹",
		  "f" => "f",
		  "t_S" => "è",
		  "x" => "H",
		  "c" => "»",
		  "Z" => "¾",
		  "u:" => "ú",
		  "o_u" => "O",
		  "J\\" => "ï",
		  "g" => "g",
		  "N" => "N",
		  "a_u" => "A",
		  "o:" => "ó",
		  "e_u" => "E",
		  "d_z" => "Z",
		  "F" => "M",
		  "d_Z" => "®",
		  " " => " ",
		  "E:" => "ä",
		  "2:" => "ö",
		  "y:" => "ü",
		  "?" => "?",
		  "@" => "@",
		  "|" => "|",
		  "*" => "*",
		"%" => "%",
		"~" => "~",
		);

    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
	$char2 = substr ( $input, $i+1, 1 ) ;
	if ( $char2 eq ":" or $char2 eq "\\"  ) {
	    $char = substr ( $input, $i, 2 ) ;
	    $i++ ;
	}
	elsif ( $char2 eq "_" ) {
	    $char = substr ( $input, $i, 3 ) ;
	    $i = $i + 2 ;
	}
	else {
	    $char = substr ( $input, $i, 1 ) ;
	}

	if ( $char eq "[" ) {
	    while ( $char ne "]" ) {
		$output = "$output$char" ;
		$i++ ;
		$char = substr ( $input, $i, 1 ) ;
	    }
	    $output = "$output$char" ;
	}
	else {
	    $output = "$output$desampify{$char}" ;
	}

    }
#	print "$output\n";
    return ( $output ) ;

}

# Konverze mezi fonet. abecedami IPA CTU (nase) a PAC (Psutka LDC)
##################################################################

sub ipactu2pac {

    ($input) = @_ ;
    local ( $output, %ipactu2pac, $i, $line_len, $char ) ;

    %ipactu2pac = (
		"e" => "e",
		"o" => "o",
		"a" => "a",
		"y" => "i",
		"t" => "t",
		"s" => "s",
		"n" => "n",
		"l" => "l",
		"r" => "r",
		"ý" => "ii",
		"k" => "k",
		"v" => "v",
		"p" => "p",
		"m" => "m",
		"d" => "d",
		"j" => "j",
		"u" => "u",
		"ò" => "nj",
		"á" => "aa",
		"z" => "z",
		"c" => "c",
		"b" => "b",
		"h" => "h",
		"ø" => "rzh",
		"Ø" => "rsh",
		"é" => "ee", 
		"¹" => "sh", 
		"f" => "f", 
		"è" => "ch",
		"H" => "x", 
		"»" => "tj", 
		"¾" => "zh", 
		"ú" => "uu", 
		"O" => "ow",
		"ï" => "dj",
		"g" => "g",
		"N" => "ng",
		"A" => "aw",
		"ó" => "oo",
		"E" => "ew",
		"Z" => "dz",
		"M" => "mg",
		"®" => "dzh",
		" " => " ",
		);

    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
	$char = substr ( $input, $i, 1 ) ;
	$output = "$output$ipactu2pac{$char} " ;
    }
    $output =~ s/ +$//g ;

    return ( $output ) ;

}

sub pac2ipactu {

    ($input) = @_ ;
    local ( @phones, $output, %pac2ipactu, $i, $i_pom ) ;

    %pac2ipactu = (
		  "e" => "e",
		  "o" => "o",
		  "a" => "a",
		  "i" => "y",
		  "t" => "t",
		  "s" => "s",
		  "n" => "n",
		  "l" => "l",
		  "r" => "r",
		  "ii" => "ý",
		  "k" => "k",
		  "v" => "v",
		  "p" => "p",
		  "m" => "m",
		  "d" => "d",
		  "j" => "j",
		  "u" => "u",
		  "nj" => "ò",
		  "aa" => "á",
		  "z" => "z",
		  "c" => "c",
		  "b" => "b",
		  "h" => "h",
		  "rzh" => "ø",
		  "rsh" => "Ø",
		  "ee" => "é",
		  "sh" => "¹",
		  "f" => "f",
		  "ch" => "è",
		  "x" => "H",
		  "tj" => "»",
		  "zh" => "¾",
		  "uu" => "ú",
		  "ow" => "O",
		  "dj" => "ï",
		  "g" => "g",
		  "ng" => "N",
		  "aw" => "A",
		  "oo" => "ó",
		  "ew" => "E",
		  "dz" => "Z",
		  "mg" => "M",
		  "dzh" => "®",
		  " " => " ",
		);

    $input =~ s/ +$//g ;
    @phones = split / /, $input  ;
    $i_pom = scalar int @phones ;
    $output = "" ;
    for ( $i = 0 ; $i < $i_pom ; $i = $i+1 ) {
#	print "$i $phones[$i]\n" ;
	$output = "$output$pac2ipactu{$phones[$i]}" ;
#	print "$output\n" ;
    }

    return ( $output ) ;

}

# SYLABIFIKACE CESKE VYSLOVNOSTI 
# Zpresnena varianta Vaskem Hanzlem dne 5/5/2008
##################################################################

sub sylabify {

    ( $input ) = @_ ;
    local ( $output ) ;

    $input =~ s/a/<a>/g ; 
    $input =~ s/e/<e>/g ;
    $input =~ s/i/<i>/g ;
    $input =~ s/o/<o>/g ;
    $input =~ s/u/<u>/g ;
    $input =~ s/A/<A>/g ;
    $input =~ s/E/<E>/g ;
    $input =~ s/O/<O>/g ;
    $input =~ s/á/<á>/g ;
    $input =~ s/é/<é>/g ;
    $input =~ s/í/<í>/g ;
    $input =~ s/ó/<ó>/g ;
    $input =~ s/ú/<ú>/g ;
    $input =~ s/y/<y>/g ;
    $input =~ s/ý/<ý>/g ;

    # T-mobile, vejr:
    $input =~ s/>jl/j>l/g ;
    $input =~ s/>jr/j>r/g ;

    $input =~ s/r</<R/g ;
    $input =~ s/>r/R>/g ;
    $input =~ s/l</<L/g ;
    $input =~ s/>l/L>/g ;
    $input =~ s/r/<r>/g ;
    $input =~ s/l/<l>/g ;

    # rvát, lví:
    $input =~ s/^<r>/r/g ;
    $input =~ s/^<l>/l/g ;
    # Washington, Houston:
    $input =~ s/tn$/<tn/g ;
    # osm:
    $input =~ s/sm$/<sm/g ;

    $input =~ s/([bpvf]j)</<$1/g ;
    $input =~ s/sk</s<k/g ;
    $input =~ s/([^>])</<$1/g ; 
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/></|/g ;
    $input =~ s/>$//g ;
    $input =~ s/^<//g ;
    $input =~ s/R/r/g ;
    $input =~ s/L/l/g ;
    $input =~ s/¹s\|tv/¹|stv/g ; 
    $input =~ s/ne\|jv/nej|v/g ;
    $input =~ s/ne\|jl/nej|l/g ;
    $input =~ s/N\|kf/Nk|f/g ;
    $input =~ s/y\|sk/ys|k/g ;
    $input =~ s/vys\|ko/vy|sko/g ;
    $input =~ s/jed\|n/je|dn/g ;
    $input =~ s/jed\|ò/je|dò/g ;
    $input =~ s/o\|bje\|dn/ob|jed|n/g ;
    $input =~ s/mark\|var/mar|kvar/g ;
    $input =~ s/nás\|tro\|j/ná|stro|j/g ;
    $input =~ s/^e\|jem$/ej|em/g ;

    # zamìøili, námìstí:
    $input =~ s/m\|òe/|mòe/g ;
    # tøást:
    $input =~ s/t\|Ø/|tØ/g ;
    # na zaèátku slova se to mohlo teï zdvojit:
    $input =~ s/\|\|/|/g ;

    return ( "|$input|" ) ;

}


# Konverze mezi fonet. abecedami IPA CTU (nase) a HTK (bez hacku a carek)
#########################################################################

sub ipactu2htk {

    ($input) = @_ ;
    local ( $output, %ipactu2htk, $i, $line_len, $char ) ;

    %ipactu2htk = (
		"e" => "e",
		"o" => "o",
		"a" => "a",
		"y" => "i",
		"t" => "t",
		"s" => "s",
		"n" => "n",
		"l" => "l",
		"r" => "r",
		"ý" => "ii",
		"k" => "k",
		"v" => "v",
		"p" => "p",
		"m" => "m",
		"d" => "d",
		"j" => "j",
		"u" => "u",
		"ò" => "nn",
		"á" => "aa",
		"z" => "z",
		"c" => "c",
		"b" => "b",
		"h" => "h",
		"ø" => "rr",  
		"Ø" => "rrr", 
		"é" => "ee", 
		"¹" => "ss", 
		"f" => "f", 
		"è" => "cc",
		"H" => "ch",  
		"»" => "tt", 
		"¾" => "zz", 
		"ú" => "uu", 
		"O" => "ou",
		"ï" => "dd",
		"g" => "g",
		"N" => "ng",
		"A" => "au",
		"ó" => "oo",
		"E" => "eu",
		"Z" => "dz",
		"M" => "mv",
		"®" => "dzz",
		"ä" => "aaa",
		"ö" => "ooo",
		"ü" => "uuu",
		" " => " ",
		"*" => "*",
		"%" => "%",
		"~" => "~",
		"?" => "gst",
		"@" => "sw",
		"0" => "sil",
		"1" => "sp",
		# "?" => "sp",
		);

    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
	$char = substr ( $input, $i, 1 ) ;
	$output = "$output$ipactu2htk{$char} " ;
    }
    $output =~ s/ +$//g ;

    return ( $output ) ;

}

sub htk2ipactu {

    ($input) = @_ ;
    local ( $output, %htk2ipactu, $i, $line_len, $char ) ;

    %htk2ipactu = (
		"e"   => "e" ,
		"o"   => "o" ,
		"a"   => "a" ,
		"i"   => "y" ,
		"y"   => "y" ,    # Toto je ovsem chybne v HTK fromatu Taraby
		"t"   => "t" ,
		"s"   => "s" ,
		"n"   => "n" ,
		"l"   => "l" ,
		"r"   => "r" ,
		"ii"  => "ý" ,
		"yy"  => "ý" ,    # Toto je ovsem chybne v HTK fromatu Taraby
		"k"   => "k" ,
		"v"   => "v" ,
		"p"   => "p" ,
		"m"   => "m" ,
		"d"   => "d" ,
		"j"   => "j" ,
		"u"   => "u" ,
		"nn"  => "ò" ,
		"aa"  => "á" ,
		"z"   => "z" ,
		"c"   => "c" ,
		"b"   => "b" ,
		"h"   => "h" ,
		"rr"  => "ø" ,  
		"rrr" => "Ø" ,
		"ee"  => "é" , 
		"ss"  => "¹" , 
		"f"   => "f" , 
		"cc"  => "è" ,
		"ch"  => "H" ,  
		"tt"  => "»" , 
		"zz"  => "¾" , 
		"uu"  => "ú" , 
		"ou"  => "O" ,
		"dd"  => "ï" ,
		"g"   => "g" ,
		"ng"  => "N" ,
		"au"  => "A" ,
		"oo"  => "ó" ,
		"eu"  => "E" ,
		"dz"  => "Z" ,
		"mv"  => "M" ,
		"dzz" => "®" ,
		"aaa" => "ä",
		"ooo" => "ö",
		"uuu" => "ü",
		"gst" => "?",
		"sw" => "@",
		" " => " ",
		"*" => "*",
		"%" => "%",
		"~" => "~",
		"sp"  => "1" ,
		"sil"  => "0" ,
		"?" => "?",   # TEZ nepresny HTK format
		"" => "",   # TEZ nepresny HTK format
		);

    # POZOR !!! FUNGUJE POR JEDNOTLIVE SYMBOLY JAKO CELEK, NELZE DELAT CELA SLOVA
    #############################################################################
    # $line_len = length ( $input ) ;
    # $output = "" ;
    # for ( $i = 0; $i < $line_len ; $i++ ) {
    # 	  $char = substr ( $input, $i, 1 ) ;
    # 	  $output = "$output$ipactu2htk{$char} " ;
    # }
    # $output =~ s/ +$//g ;

    $output = "$htk2ipactu{$input}" ;
    return ( $output ) ;

}

# Konverze mezi fonet. abecedami IPA CTU (nase) a cuni FF (cuni FF)
##################################################################

sub ipactu2cuniff {

    ($input) = @_ ;
    local ( $output, %ipactu2cuniff, $i, $line_len, $char ) ;

    %ipactu2cuniff = (
		"e" => "e",
		"o" => "o",
		"a" => "a",
		"y" => "i",
		"t" => "t",
		"s" => "s",
		"n" => "n",
		"l" => "l",
		"r" => "r",
		"ý" => "i:",
		"k" => "k",
		"v" => "v",
		"p" => "p",
		"m" => "m",
		"d" => "d",
		"j" => "j",
		"u" => "u",
		"ò" => "ò",
		"á" => "a:",
		"z" => "z",
		"c" => "c",
		"b" => "b",
		"h" => "h",
		"ø" => "ø",
		"Ø" => "Ø",
		"é" => "e:", 
		"¹" => "¹", 
		"f" => "f", 
		"è" => "è",
		"H" => "x",  
		"»" => "»", 
		"¾" => "¾", 
		"ú" => "u:", 
		"O" => "ou",
		"ï" => "ï",
		"g" => "g",
		"N" => "N",
		"A" => "au",
		"ó" => "o:",
		"E" => "eu",
		"Z" => "dz",
		"M" => "M",
		"®" => "d¾",
		"ä" => "ä",
		"ö" => "ö",
		"ü" => "ü",
		" " => " ",
		"'" => "'",
		);

    $line_len = length ( $input ) ;
    $output = "" ;


     #    for ( $i = 0; $i < $line_len ; $i++ ) {
    $i = 0; 
    do {
	$char = substr ( $input, $i, 1 ) ;

        # text mezi dvema #xxxx# se prevede beze zmeny
	if ( $char =~ /\#/ ) {
	    $output = "$output$char" ;
	    do {
		$i++ ;
		$char = substr ( $input, $i, 1 ) ;
		$output = "$output$char" ;
	    } while ( $char ne "\#" ) ;
	}
	else {
	    $output = "$output$ipactu2cuniff{$char} " ;
	}
	
	$i++ ;

    } while ( $i < $line_len ) ;
    $output =~ s/ +$//g ;

    return ( $output ) ;

}

sub cuniff2ipactu {

    ($input) = @_ ;
    local ( @phones, $output, %cuniff2ipactu, $i, $i_pom ) ;

    %cuniff2ipactu = (
		  "e" => "e",
		  "o" => "o",
		  "a" => "a",
		  "i" => "y",
		  "t" => "t",
		  "s" => "s",
		  "n" => "n",
		  "l" => "l",
		  "r" => "r",
		  "i:" => "ý",
		  "k" => "k",
		  "v" => "v",
		  "p" => "p",
		  "m" => "m",
		  "d" => "d",
		  "j" => "j",
		  "u" => "u",
		  "ò" => "ò",
		  "a:" => "á",
		  "z" => "z",
		  "c" => "c",
		  "b" => "b",
		  "h" => "h",
		  "ø" => "ø",
		  "Ø" => "Ø",
		  "e:" => "é",
		  "¹" => "¹",
		  "f" => "f",
		  "è" => "è",
		  "x" => "H",    
		  "»" => "»",
		  "¾" => "¾",
		  "u:" => "ú",
		  "ou" => "O",
		  "ï" => "ï",
		  "g" => "g",
		  "N" => "N",
		  "au" => "A",
		  "o:" => "ó",
		  "eu" => "E",
		  "dz" => "Z",
		  "M" => "M",
		  "d¾" => "®",
		  "ä" => "ä",
		  "ö" => "ö",
		  "ü" => "ü",
		  " " => " ",
		  "'" => "'",
		);


    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
        $pom = substr ( $input, $i, 2 )  ;
	if ( $pom =~ /au|eu|ou|dz|d¾|.:/ ) {
	    $char = substr ( $input, $i, 2 ) ;
	    $i++ ;
	}
	else {
	    $char = substr ( $input, $i, 1 ) ;
	}
	$output = "$output$cuniff2ipactu{$char}" ;
    }

    return ( $output ) ;

}


# Konverze mezi fonet. abecedami IPA CTU (nase) a cuni FF (cuni FF)
##################################################################

sub ipactu2volin {

    ($input) = @_ ;
    local ( $output, %ipactu2cuniff, $i, $line_len, $char ) ;

    %ipactu2cuniff = (
		"e" => "e",
		"o" => "o",
		"a" => "a",
		"y" => "i",
		"t" => "t",
		"s" => "s",
		"n" => "n",
		"l" => "l",
		"r" => "r",
		"ý" => "i:",
		"k" => "k",
		"v" => "v",
		"p" => "p",
		"m" => "m",
		"d" => "d",
		"j" => "j",
		"u" => "u",
		"ò" => "nj",
		"á" => "a:",
		"z" => "z",
		"c" => "c",
		"b" => "b",
		"h" => "h",
		"ø" => "R",
		"Ø" => "R0",
		"é" => "e:", 
		"¹" => "S", 
		"f" => "f", 
		"è" => "C",
		"H" => "x",  
		"»" => "T", 
		"¾" => "Z", 
		"ú" => "u:", 
		"O" => "ou",
		"ï" => "D",
		"g" => "g",
		"N" => "N",
        	"ò" => "nj",
		"A" => "au",
		"ó" => "o:",
		"E" => "eu",
		"Z" => "dz",
		"M" => "M",
		"®" => "dZ",
		"ä" => "ä",
		"ö" => "ö",
		"ü" => "ü",
		"?" => "?",
		"@" => "@",
		" " => " ",
		"'" => "'",
		"*" => "*",
		"~" => "~",
		"%" => "%",
		"0" => "\#SIL\#",
		"1" => "\#SP\#",
		"" => "",      # Pro spravne prevedeni prazdneho retezce
  		);

    $line_len = length ( $input ) ;
    $output = "" ;


     #    for ( $i = 0; $i < $line_len ; $i++ ) {
    $i = 0; 
    do {
	$char = substr ( $input, $i, 1 ) ;

        # text mezi dvema #xxxx# se prevede beze zmeny
	if ( $char =~ /\#/ ) {
	    $output = "$output$char" ;
	    do {
		$i++ ;
		$char = substr ( $input, $i, 1 ) ;
		$output = "$output$char" ;
	    } while ( $char ne "\#" ) ;
	}
	else {
	    $output = "$output$ipactu2cuniff{$char} " ;
	}
	
	$i++ ;

    } while ( $i < $line_len ) ;
    $output =~ s/ +$//g ;

    return ( $output ) ;

}

sub volin2ipactu {

    ($input) = @_ ;
    local ( @phones, $output, %cuniff2ipactu, $i, $i_pom ) ;

    %cuniff2ipactu = (
		  "e" => "e",
		  "o" => "o",
		  "a" => "a",
		  "i" => "y",
		  "t" => "t",
		  "s" => "s",
		  "n" => "n",
		  "l" => "l",
		  "r" => "r",
		  "i:" => "ý",
		  "k" => "k",
		  "v" => "v",
		  "p" => "p",
		  "m" => "m",
		  "d" => "d",
		  "j" => "j",
		  "u" => "u",
		  "nj" => "ò",  ## ???? NOT IN THIS SET
		  "a:" => "á",
		  "z" => "z",
		  "c" => "c",
		  "b" => "b",
		  "h" => "h",
		  "R" => "ø",
		  "R0" => "Ø",  ## Neznele "ø"
		  "e:" => "é",
		  "S" => "¹",
		  "f" => "f",
		  "C" => "è",
		  "x" => "H",    
		  "X" => "H",   ## VERZE "x" - CLEARED
		  "T" => "»",
		  "Z" => "¾",
		  "u:" => "ú",
		  "ou" => "O",
		  "D" => "ï",
		  "g" => "g",
		  "N" => "N",   ## banka, maminka, ....
		  "au" => "A",
		  "o:" => "ó",
		  "eu" => "E",
		  "dz" => "Z",  ## ???? NOT IN THIS SET
		  "M" => "M",   ## tramvaj, triumf, ... ???? NOT IN THIS SET
		  "dZ" => "®",  ## ???? NOT IN THIS SET
		  "ä" => "ä",   ## German phones .. ???? NOT IN THIS SET
		  "ö" => "ö",   ## German phones .. ???? NOT IN THIS SET
		  "ü" => "ü",   ## German phones .. ???? NOT IN THIS SET
		  " " => " ",
		  "SP" => "1",
		  "sp" => "1",
		  "'" => "'",
		  ## "@" => "@",  ## Temporary remove for SpeechDat models
		  ## "@:" => "@",
		  "@" => "@",
		  "\@:" => "@",
		  "?" => "?",
		  # "" => "",
		);


    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
        $pom = substr ( $input, $i, 2 )  ;
	if ( $pom =~ /au|eu|ou|dz|dZ|R0|nj|SP|sp|.:/ ) {
	    $char = substr ( $input, $i, 2 ) ;
	    $i++ ;
	}
	else {
	    $char = substr ( $input, $i, 1 ) ;
	}
	$output = "$output$cuniff2ipactu{$char}" ;
	# print "$char\n" ;
    }

    return ( $output ) ;

}

# Konverze mezi fonet. abecedami IPASK CTU (nase) a Slovak SAMPA
##################################################################

sub sampify_sk {

    ($input) = @_ ;
    local ( $output, %sampify, $i, $line_len, $char ) ;

    %sampify = (
		"e" => "e",
		"o" => "o",
		"a" => "a",
		"y" => "i",
		"t" => "t",
		"s" => "s",
		"n" => "n",
		"l" => "l",
		"r" => "r",
		"ý" => "i:",
		"k" => "k",
		"v" => "v",
		"p" => "p",
		"m" => "m",
		"d" => "d",
		"j" => "j",
		"u" => "u",
		"ò" => "J",
		"á" => "a:",
		"z" => "z",
		"c" => "t_s",
		"b" => "b",
		"h" => "h\\",
		"é" => "e:", 
		"¹" => "S", 
		"f" => "f", 
		"è" => "t_S",
		"H" => "x", 
		"»" => "c", 
		"¾" => "Z", 
		"ú" => "u:", 
		"ï" => "J\\",
		"g" => "g",
		"N" => "N",
		"ó" => "o:",
		"Z" => "d_z",
		"M" => "F",
		"®" => "d_Z",
		" " => " ",
		"ä" => "{",
		"J" => "i_^",
		"A" => "i_^a",
		"E" => "i_^e",
		"U" => "i_^u",
		"L" => "l=",
		"Å" => "l=:",
		"µ" => "L",
		"S" => "N\\",
		"R" => "r=",
		"À" => "r=:",
		"V" => "u_^",
		"ô" => "u_^o",
		"w" => "w",
		"?" => "?",
		"@" => "@",
		"|" => "|",
		"*" => "*",
		"~" => "~",
		"%" => "%",
		"1" => " ",
		);

    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
	$char = substr ( $input, $i, 1 ) ;
	if ( $char eq "[" ) {
	    while ( $char ne "]" ) {
		$output = "$output$char" ;
		$i++ ;
		$char = substr ( $input, $i, 1 ) ;
	    }
	    $output = "$output$char" ;
	}
	else {
	    $output = "$output$sampify{$char}" ;
	}
    }

    return ( $output ) ;

}

sub desampify_sk {

    ($input) = @_ ;
    local ( $output, %desampify, $i, $line_len, $char, $char2 ) ;

    %desampify = (
		  "e" => "e",
		  "o" => "o",
		  "a" => "a",
		  "i" => "y",
		  "t" => "t",
		  "s" => "s",
		  "n" => "n",
		  "l" => "l",
		  "r" => "r",
		  "i:" => "ý",
		  "k" => "k",
		  "v" => "v",
		  "p" => "p",
		  "m" => "m",
		  "d" => "d",
		  "j" => "j",
		  "u" => "u",
		  "J" => "ò",
		  "a:" => "á",
		  "z" => "z",
		  "t_s" => "c",
		  "b" => "b",
		  "h\\" => "h",
		  "e:" => "é",
		  "S" => "¹",
		  "f" => "f",
		  "t_S" => "è",
		  "x" => "H",
		  "c" => "»",
		  "Z" => "¾",
		  "u:" => "ú",
		  "J\\" => "ï",
		  "g" => "g",
		  "N" => "N",
		  "o:" => "ó",
		  "d_z" => "Z",
		  "F" => "M",
		  "d_Z" => "®",
		  " " => " ",
                "{" => "ä",
		"i_^" => "J",
		"i_^a" => "A",
		"i_^e" => "E",
		"i_^u" => "U",
		"l=" => "L",
		"l=:" => "Å",
		"L" => "µ",
		"N\\" => "S",
		"r=" => "R",
		"r=:" => "À",
		"u_^" => "V",
		"u_^o" => "ô",
		"w" => "w",
		  "?" => "?",
		  "@" => "@",
		  "|" => "|",
		  "*" => "*",
                  "%" => "%",
		  "~" => "~",
		);

    $line_len = length ( $input ) ;
    $output = "" ;
    for ( $i = 0; $i < $line_len ; $i++ ) {
	$char2 = substr ( $input, $i+1, 1 ) ;
	if ( $char2 eq ":" or $char2 eq "\\"  ) {
	    $char = substr ( $input, $i, 2 ) ;
	    $i++ ;
	}
	elsif ( $char2 eq "_" ) {
	    $char = substr ( $input, $i, 3 ) ;
	    $i = $i + 2 ;
	}
	else {
	    $char = substr ( $input, $i, 1 ) ;
	}

	if ( $char eq "[" ) {
	    while ( $char ne "]" ) {
		$output = "$output$char" ;
		$i++ ;
		$char = substr ( $input, $i, 1 ) ;
	    }
	    $output = "$output$char" ;
	}
	else {
	    $output = "$output$desampify{$char}" ;
	}

    }

    return ( $output ) ;

}

sub sylabify_sk {

    # Verze pro SK
    # Na rozdil od CZ, v SK uz mame primo pri prepisu vyslovnosti pomoci
    # transc_sk oznaceny slabikotvorne souhlasky: R À L Å
    # Tyto varianty slabikotvorne nejsou: r à l å
    # Vyse uvedena R a L jsou s CARKOU. Verze L s HACKEM neni slabikotvorna
    # nikdy a zde se o ni nijak zvlast nestarame. Dlouhe R je slabikotvorne vzdy,
    # takze male r s carkou v IFA vubec neexistuje. (Velka/mala znaci v IFA
    # slabikotvornost R a L.)
    # Zvlastni samohlasky a dvojhlasky jsou A E U J ô ä

    ( $input ) = @_ ;
    local ( $output ) ;

    # Mark sylab. kernels:
    $input =~ s/a/<a>/g ; 
    $input =~ s/e/<e>/g ;
    $input =~ s/i/<i>/g ;
    $input =~ s/o/<o>/g ;
    $input =~ s/u/<u>/g ;
    $input =~ s/A/<A>/g ;
    $input =~ s/E/<E>/g ;
    $input =~ s/U/<U>/g ;
    $input =~ s/J/<J>/g ;
    $input =~ s/á/<á>/g ;
    $input =~ s/é/<é>/g ;
    $input =~ s/í/<í>/g ;
    $input =~ s/ó/<ó>/g ;
    $input =~ s/ú/<ú>/g ;
    $input =~ s/y/<y>/g ;
    $input =~ s/ý/<ý>/g ;
    $input =~ s/ä/<ä>/g ;
    $input =~ s/ô/<ô>/g ;
    $input =~ s/R/<R>/g ;
    $input =~ s/À/<À>/g ;
    $input =~ s/L/<L>/g ;
    $input =~ s/Å/<Å>/g ;

    # Prevent some errors we would make below in the gluing phase:
    # This worked for CZ. Might need tuneup for SK.
    $input =~ s/([bpvf]j)</<$1/g ;
    $input =~ s/sk</s<k/g ;

    # Glue surrounding consonants to kernels, forming growing chunks:
    $input =~ s/([^>])</<$1/g ; 
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;
    $input =~ s/([^>])</<$1/g ;
    $input =~ s/>([^<])/$1>/g ;

    # Touching point of two chunks is sylab. boundary:
    $input =~ s/></|/g ;
    # Chunk marks at begin/end just go away (they have nothing to touch):
    $input =~ s/>$//g ;
    $input =~ s/^<//g ;

    # Though Slovak SAMPA does not mark 'au' and 'ou' as one unit, most
    # likely it behaves as ONE syl. kernel. Fix it here:
    $input =~ s/a\|u/au/g ;
    $input =~ s/o\|u/ou/g ;

    # Fix some common errors - this worked for CZ.
    # Might need tuneup for SK.
    $input =~ s/¹s\|tv/¹|stv/g ; 
    $input =~ s/ne\|jv/nej|v/g ;
    $input =~ s/ne\|jl/nej|l/g ;
    $input =~ s/N\|kf/Nk|f/g ;
    $input =~ s/y\|sk/ys|k/g ;
    $input =~ s/vys\|ko/vy|sko/g ;
    $input =~ s/jed\|n/je|dn/g ;
    $input =~ s/jed\|ò/je|dò/g ;
    $input =~ s/o\|bje\|dn/ob|jed|n/g ;
    $input =~ s/mark\|var/mar|kvar/g ;
    $input =~ s/nás\|tro\|j/ná|stro|j/g ;
    $input =~ s/^e\|jem$/ej|em/g ;

    # Add sylab. boundary also at begin/end:
    return ( "|$input|" ) ;

}

# TOTO MUSI BYT NA KONCI 
# Po uplnem provedeni se tato hodnota vraci jako signalizace uspesneho nacteni
#################################################################################

1 ;

