#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';

my $valid = 0;
while (<>) {
    my ($f, $t, $l, $p) = m/(\d+)-(\d+) (.): (.*)$/g;
    my @m = grep { substr($p, $_-1, 1) eq  $l } ($f, $t);
    $valid++ if @m==1;
}

say "$valid";
