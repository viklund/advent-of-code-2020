#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';

my $valid = 0;
while (<>) {
    my ($f, $t, $l, $p) = m/(\d+)-(\d+) (.): (.*)$/g;
    my @l = grep { $_ eq $l } split //, $p;
    if ( $f <= @l && @l <= $t) {
        $valid++;
    }
}

say "$valid";
