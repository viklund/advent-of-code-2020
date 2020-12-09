#!/usr/bin/env perl
use strict;
use warnings;

use feature qw/say/;
use List::Util qw/sum0/;

my @buff;

my $target = 21806024;

while (<>) {
    chomp;
    push @buff, $_;

    while ( (sum0 @buff) > $target ) {
        shift @buff;
    }

    my $s = sum0 @buff;
    if ($s == $target) {
        my @s = sort { $a <=> $b } @buff;
        say $s[0] + $s[-1];
        exit;
    }
}
