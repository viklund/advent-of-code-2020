#!/usr/bin/env perl
use strict;
use warnings;

use feature 'say';

my @map;
while (<>) {
    chomp;
    push @map, [split //, $_];
}

my $m=1;
for my $slope ([1,1], [1,3], [1,5], [1,7], [2,1]) {
    $m *= check_slope(@$slope);
}
say $m;

sub check_slope {
    my $d = shift;
    my $n = shift;

    my $pos = 0;
    my $trees = 0;
    my $rowi = 0;
    while ($rowi <= $#map) {
        $rowi+=$d;
        my $row = $map[$rowi];
        last if $rowi > $#map;
        $pos += $n;
        if ($pos > $#$row) {
            $pos %= @$row;
        }
        if ($row->[$pos] eq '#') {
            $trees++;
        }
    }
    return $trees;
}
