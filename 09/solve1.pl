#!/usr/bin/env perl
use strict;
use warnings;

use feature qw/say/;

my @buff;

for (1..25) {
    my $l = <>;
    chomp $l;
    push @buff, $l;
}

while (<>) {
    chomp;
    if ( ! find($_) ) {
        say $_;
        exit;
    }
    push @buff, $_;
    shift @buff;
}

sub find {
    my $num = shift;
    for my $ni (0..$#buff-1) {
        for my $nj ($ni+1..$#buff) {
            if ( $buff[$ni] + $buff[$nj] == $num ) {
                return 1;                
            }
        }
    }
    return;
}
