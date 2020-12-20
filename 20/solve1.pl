#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();
use Data::Dumper;


my %tiles;
my $tn;

# Parse tiles
while (<>) {
    chomp;
    if (/^Tile (\d+)/) {
        $tn = $1;
        next;
    }
    if (/^(\.|#)+$/) {
        push @{ $tiles{$tn} }, [ split //, $_ ];
        next;
    }
    if (/^\s*$/) {
        next;
    }
}

# Index tile edges
my %index;
while (my ($tn, $t) = each %tiles) {
    my $top = join "", @{ $t->[0] };
    my $bot = join "", @{ $t->[-1] };

    my $left  = join "", map { $_->[0] } @$t;
    my $right = join "", map { $_->[-1] } @$t;

    # string of edge and then empty string if free, 1 if it's fixed
    push @{ $index{$tn} }, [$top, ''];
    push @{ $index{$tn} }, [$bot, ''];
    push @{ $index{$tn} }, [$left, ''];
    push @{ $index{$tn} }, [$right, ''];
}

# Build matches
TILE:
for my $tn (keys %tiles) {
    #$tn = '2473';
    for my $ei ( 0 .. $#{ $index{$tn} } ) {

        for my $on (keys %index) {
            next if $on eq $tn;

            for my $oi ( 0 .. $#{ $index{$on} } ) {
                #printf "Comp $tn($ei)   $on($oi)    %s  %s\n", $index{$tn}[$ei][0], $index{$on}[$oi][0];
                if ( match_edge($index{$tn}[$ei][0], $index{$on}[$oi][0]) ) {
                    say "    Matched $tn($ei)  with  $on($oi)";
                    $index{$tn}[$ei][1]++;
                }
            }
        }
    }
}

# Find tiles with 2 edges left
my $mult = 1;
my $nmult = 0;
for my $tn (keys %tiles) {
    my $nedge = grep { $_->[1] eq '' } @{ $index{$tn} };
    if ( $nedge == 2 ) {
        $mult *= $tn;
        $nmult++;
    }
    say "$tn  $nedge";
}

say "$nmult $mult";



sub match_edge {
    my ($e1, $e2) = @_;
    return 1 if $e1 eq $e2;
    return 1 if $e1 eq reverse $e2;
    return '';
}




__END__
Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

