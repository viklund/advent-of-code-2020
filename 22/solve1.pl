#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw(sum);

my (@player1, @player2);

my $player;
while (<>) {
    chomp;
    if (/^Player 1/) {
        $player = 1;
        next;
    }
    if (/^Player 2/) {
        $player = 2;
        next;
    }
    if (/^\s*$/) {
        next;
    }
    if ($player == 1) {
        push @player1, $_;
        next;
    }
    if ($player == 2) {
        push @player2, $_;
        next;
    }
    die "WTF";
}

while ( @player1 && @player2 ) {
    my ($c1,$c2) = (shift @player1, shift @player2);
    if ( $c1 > $c2 ) {
        push @player1, $c1, $c2;
    }
    if ( $c2 > $c1 ) {
        push @player2, $c2, $c1;
    }
}

my @all = (@player1, @player2);

my $score = sum map { $all[$_] * ($#all-$_+1) }  0..$#all;
say $score;
