#!/usr/bin/env perl

use strict;
use warnings;

my @numbers;
while (<>) {
    chomp;
    push @numbers, $_;
}

for my $ii (0..$#numbers-2) {
    for my $jj ($ii+1..$#numbers-1) {
        for my $kk ($jj+1..$#numbers) {
            if ($numbers[$ii] + $numbers[$jj] + $numbers[$kk] == 2020) {
                printf "%3d %3d %3d: %4d+%4d+%4d=2020  ANS: %d\n",
                    $ii, $jj, $kk,
                    @numbers[$ii, $jj, $kk],
                    $numbers[$ii]*$numbers[$jj]*$numbers[$kk];
            }
        }
    }
}

