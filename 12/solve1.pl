#!/usr/bin/env perl

use strict;
use warnings;

use feature qw/ say switch /;
no warnings "experimental::smartmatch";

my @dirs = qw/ E S W N /;
my $dir = 0;

# x, y
my @pos = (0,0);

while (<>) {
    my ($t, $l) = /^(.)(\d+)$/;
    if ( $t eq 'R' ) {
        $l /= 90;
        $dir = ($dir+$l)%4;
        next;
    }
    if ( $t eq 'L' ) {
        $l /= 90;
        $dir = ($dir-$l)%4;
        next;
    }
    if ( $t eq 'F' ) {
        $t = $dirs[$dir];
    }

    for ($t) {
        when('E') { $pos[0] += $l }
        when('S') { $pos[1] -= $l }
        when('W') { $pos[0] -= $l }
        when('N') { $pos[1] += $l }
    }
}

say abs($pos[0]) + abs($pos[1]);
