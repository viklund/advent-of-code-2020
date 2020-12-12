#!/usr/bin/env perl

use strict;
use warnings;

use feature qw/ say switch /;
no warnings "experimental::smartmatch";

use Math::Trig qw/deg2rad/;

# x, y
my @pos = (10,1);
my @ship_pos = (0,0);

while (<>) {
    my ($t, $l) = /^(.)(\d+)$/;
    if ( $t =~ /R|L/ ) {
        $l = deg2rad($l);
        $l = -$l if $t eq 'L';
        my @tpos;
        $tpos[0] = int( $pos[0] * cos($l) + $pos[1] * sin($l));
        $tpos[1] = int(-$pos[0] * sin($l) + $pos[1] * cos($l));
        @pos = @tpos;
        next;
    }
    if ( $t eq 'F' ) {
        $ship_pos[0] += $l * $pos[0];
        $ship_pos[1] += $l * $pos[1];
        next;
    }

    for ($t) {
        when('E') { $pos[0] += $l }
        when('S') { $pos[1] -= $l }
        when('W') { $pos[0] -= $l }
        when('N') { $pos[1] += $l }
    }
}

say abs($ship_pos[0]) + abs($ship_pos[1]);
