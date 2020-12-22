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


my ($winner, $score) = play( \@player1, \@player2, 1 );
say "$winner $score";

sub play {
    my ($p1, $p2) = @_;
    my @p1 = @$p1; # Copy
    my @p2 = @$p2; # Copy

    my %seen_hands = ();

    my $hand = 0;
    while ( @p1 && @p2 ) {
        my $d = join("-", "p1", @p1, "p2", @p2);
        return 'p1' if $seen_hands{$d}++;

        my ($c1,$c2) = (shift @p1, shift @p2);

        # Time for a sub game!
        if ( $c1 <= @p1 && $c2 <= @p2 ) {
            my $res = play([@p1[0..$c1-1]], [@p2[0..$c2-1]]);
            if ( $res eq 'p1' ) {
                push @p1, $c1, $c2;
            }
            if ( $res eq 'p2' ) {
                push @p2, $c2, $c1;
            }
            next;
        }
        if ( $c1 > $c2 ) {
            push @p1, $c1, $c2;
            next;
        }
        if ( $c2 > $c1 ) {
            push @p2, $c2, $c1;
            next;
        }
    }

    my $winner = @p1 ? 'p1' : 'p2';

    if (wantarray) {
        my @all = (@p1, @p2);
        my $score = sum map { $all[$_] * ($#all-$_+1) }  0..$#all;
        return ($winner, $score);
    }
    return $winner;
}
