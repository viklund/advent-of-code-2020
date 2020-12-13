#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say );

my $now = <>;
chomp($now);

my $buses = <>;
chomp $buses;
my @buses = split ',', $buses;

my $earliest = $now*2;
my $id = 0;

for my $b ( @buses ) {
    next if $b eq 'x';
    my $s = 0;
    $s += $b while $s < $now;
    if ( $s < $earliest ) {
        $earliest = $s;
        $id = $b;
    }
}

say "",($earliest-$now)*$id;
