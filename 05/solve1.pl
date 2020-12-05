#!/usr/bin/env perl
use strict;
use warnings;
use feature qw( say );

while (<>) {
    chomp;
    my @l = split //, $_;
    my ($l,$h) = (0,127);
    for (@l[0..6]) {
        if ( $_ eq 'F' ) {
            $h = $h - ( $h - $l + 1 )/2;
        }
        if ( $_ eq 'B' ) {
            $l = $l + ( $h - $l + 1)/2;
        }
    }
    if ( $l != $h ) {
        die "Wrong with input row on line $.\n";
    }
    my $row = $l;

    ($l,$h) = (0,7);
    for (@l[7..9]) {
        if ( $_ eq 'L' ) {
            $h = $h - ( $h - $l + 1 )/2;
        }
        if ( $_ eq 'R' ) {
            $l = $l + ( $h - $l + 1)/2;
        }
    }
    if ( $l != $h ) {
        die "Wrong with input row on line $.\n";
    }
    my $col = $l;

    my $id = $row*8 + $col;
    say $id;
}
