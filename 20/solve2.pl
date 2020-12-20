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
    push @{ $index{$tn} }, [$top,   0];
    push @{ $index{$tn} }, [$right, 0];
    push @{ $index{$tn} }, [$bot,   0];
    push @{ $index{$tn} }, [$left,  0];
}

my %tile_lookup;
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
                    $tile_lookup{$tn}{$ei} = [ $on, $oi ];
                    $index{$tn}[$ei][1]++;
                }
            }
        }
    }
}

# Find tiles with 2 edges left
my $start_tile;
for my $tn (keys %tiles) {
    my $nedge = grep { $_->[1] == 0 } @{ $index{$tn} };
    if ( $nedge == 2 ) {
        $start_tile = $tn;
    }
}

#$start_tile = '1951';

my %placed = ( $start_tile => 1 );
my @map = ( [$start_tile] );
## Build first row
TILE:
while (1) {
    my $this = $map[0][-1];
    my @neighbors = get_neighbors_tn( $this );
    # Only pick neighbors with 2 neighbors or less, (first row)
    NEIGHBOR:
    for my $n ( @neighbors ) {
        my @ns = get_neighbors_tn($n);
        next NEIGHBOR if @ns > 3;
        next NEIGHBOR if $placed{ $n };

        push @{ $map[0] }, $n;
        $placed{$n}++;

        last TILE if @ns == 2;
        next TILE;
    }
}


## Build all other rows
my $c_row = 1;
ROW:
while (1) {
    my $above = $map[-1][0];
    my @available = grep { ! exists $placed{$_} } get_neighbors_tn( $above );
    last ROW if @available != 1;
    push @map, [ $available[0] ];
    $placed{ $available[0] }++;

    my $c_idx = 1;
    TILE:
    while (1) {
        my $prev = $map[$c_row][$c_idx-1];
        my @available = grep { ! exists $placed{$_} } get_neighbors_tn( $prev );
        # Check if neighbor of top tile
        my @top_req = grep { ! exists $placed{$_} } get_neighbors_tn( $map[$c_row-1][$c_idx] );
        die if @top_req != 1;

        # Intersect just to validate that we match (probably not needed)
        my @int = grep { $_ eq $top_req[0] } @available;
        die unless @int == 1;
        
        push @{ $map[$c_row] }, $int[0];
        $placed{$int[0]}++;

        $c_idx++;
        last TILE if @{ $map[-1] } == @{ $map[0] };
    }
    $c_row++;
}

## Map built
say "MAP";
say join(" ", @$_) for @map;

## Merge map
my @big_one;
for my $row ( 0..$#map ) {
    for my $col ( 0..$#map ) {
        my $tn = $map[$row][$col];
        my $tile = $tiles{ $tn };
        say "- - - - - - - - - - - - - - - -\nPlacing $tn";
        say join("", @$_) for @$tile;

        if ( $row == 0 && $col == 0 ) {
            say "NEIGHBOR ", join(' :: ', map { join " ", @$_ } @{ $index{$tn} } );
            my $rot = 0;
            if ( $index{$tn}[0][1] >= 1 ) {
                $rot++;
            }
            if ( $index{$tn}[3][1] >= 1 ) {
                $rot++;
                $rot += 2 if $index{$tn}[2][1] >= 1;
            }
            #my $r = rotate( $tile, $rot );
            my $r = rotate( $tile, $rot );

            for my $ii ( 0 .. $#$r ) {
                for my $jj ( 0 .. $#{ $r->[$ii] } ) {
                    $big_one[$ii][$jj] = $r->[$ii][$jj];
                }
            }
            big();
            next;
        }
        if ( $col > 0 ) {
            my $last_edge = join '', map { $big_one[$_][-1] } 0..9;
            big();
            say "LAST: $last_edge";

            EDGE:
            for my $edge_index ( 0..3 ) {
                my $edge = $index{$tn}[$edge_index][0];
                say "EDGE: $edge";

                if ( $last_edge eq $edge ) {
                    ## Found it, just rotate and push
                    my $r = rotate($tile, 3-$edge_index);
                    say "ROTTED";
                    say join("", @$_) for @$r;
                    for my $ii ( 0 .. $#$r ) {
                        for my $jj ( 0 .. $#{ $r->[$ii] } ) {
                            $big_one[ $ii + $row*10 ][ $jj + $col*10 ] = $r->[$ii][$jj];
                        }
                    }
                    big();
                    exit;
                }
                if ( $last_edge eq reverse $edge ) {
                    my $r = rotate( flip($tile), $edge_index);
                    say "ROT FLIPPED";
                    say join("", @$_) for @$r;
                    exit;
                }
            }
            exit;
        }
    }
}

sub flip {
    my ($tile) = @_;

    my $dim = $#$tile;
    my @out;
    for my $row (0..$dim) {
        for my $col (0..$dim) {
            $out[ $row ][ $dim - $col ] = $tile->[$row][$col];
        }
    }
    return \@out;
}

sub rotate {
    my ( $tile, $rot ) = @_;
    say "ROTATE $rot";
    return $tile if $rot == 0;
    my @out = ();
    my $dim = $#$tile;

    if ( $rot == 3 ) {
        for my $row (0..$dim) {
            for my $col (0..$dim) {
                $out[ $dim-$col ][ $row ] = $tile->[$row][$col];
            }
        }
    }
    if ( $rot == 2 ) {
        for my $row (0..$dim) {
            for my $col (0..$dim) {
                $out[ $dim-$row ][ $dim-$col ] = $tile->[$row][$col];
            }
        }
    }
    if ( $rot == 1 ) {
        for my $row (0..$dim) {
            for my $col (0..$dim) {
                $out[ $col ][ $dim-$row ] = $tile->[$row][$col];
            }
        }
    }
    return \@out;
}


sub big {
    say "BIG";
    say join("", @$_) for @big_one;
}


sub get_neighbors_tn {
    my $tn = shift;
    return map { $_->[0] } values %{ $tile_lookup{ $tn } };
}

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

