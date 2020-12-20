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
        if ( !defined $start_tile || $tn < $start_tile ) {
            $start_tile = $tn;
        }
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
ROW:
for my $row ( 0..$#map ) {
    COL:
    for my $col ( 0..$#map ) {
        my $tn = $map[$row][$col];
        my $tile = $tiles{ $tn };
        say "- - - - - - - - - - - - - - - -\nPlacing $row $col $tn";
        big();
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
            next;
        }
        if ( $col == 0 && $row > 0 ) {
            say " NEW ROW";
            my $last_edge = join '', map { $big_one[-1][$_] } 0..9;
            my $r = $tile;
            say "LAST: $last_edge";

            EDGE:
            for my $edge_index ( 0..3 ) {
                my $edge = get_edge($tile, $edge_index);
                say "EDGE($edge_index): $edge";

                if ( $last_edge eq $edge ) {
                    ## Found it, just rotate and push
                    $r = rotate($r, 3-$edge_index);
                    $r = rotate($r, 1);
                    say "ROTTED";
                    next EDGE;
                }
                if ( $last_edge eq reverse $edge ) {
                    $r = flip( $r );
                    # rot 1 and flip => only flip
                    # rot 0 and flip => flip rot 3
                    $r = rotate($r, $edge_index);
                    #if ( $edge_index == 3 ) {
                    #    $r = rotate($r, $edge_index);
                    #}
                    #if ( $edge_index == 2 ) {
                    #    $r = rotate($r, $edge_index);
                    #}
                    say "ROT FLIPPED";
                    last EDGE;
                }
            }

            say join("", @$_) for @$r;
            for my $ii ( 0 .. $#$r ) {
                for my $jj ( 0 .. $#{ $r->[$ii] } ) {
                    $big_one[ $ii + $row*10 ][ $jj + $col*10 ] = $r->[$ii][$jj];
                }
            }
            next;
        }
        if ( $col > 0 ) {
            my $last_edge = join '', reverse map { $big_one[$_ + $row*10 ][-1] } 0..9;
            say "LAST: $last_edge";

            EDGE:
            for my $edge_index ( 0..3 ) {
                my $edge = get_edge($tile, $edge_index);
                say "EDGE($edge_index): $edge";

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
                    next COL;
                }
                if ( $last_edge eq reverse $edge ) {
                    my $r = flip( $tile );
                    # rot 1 and flip => only flip
                    # rot 0 and flip => flip rot 3
                    if ( $edge_index == 0 ) {
                        $r = rotate($r, 3);
                    }
                    if ( $edge_index == 2 ) {
                        $r = rotate($r, 1);
                    }
                    if ( $edge_index == 3 ) {
                        $r = rotate($r, 2);
                    }
                    say "ROT FLIPPED";
                    say join("", @$_) for @$r;

                    for my $ii ( 0 .. $#$r ) {
                        for my $jj ( 0 .. $#{ $r->[$ii] } ) {
                            $big_one[ $ii + $row*10 ][ $jj + $col*10 ] = $r->[$ii][$jj];
                        }
                    }
                    next COL;
                }
            }

            say "MAP";
            say join(" ", @$_) for @map;

            die "WTF";
        }
    }
}



big();

say scalar( @big_one );

my @prunes = map { ($_*10, $_*10+9) }  0..11;
for my $p ( reverse @prunes ) {
    say "Splicing $p";
    splice @big_one, $p, 1;
    for my $col ( @big_one ) {
        splice @$col, $p, 1;
    }
}

say join("", @$_) for @big_one;


#### Look for monsters
my @pattern = map { [split //, $_] } (
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   ");

my @positions;
for my $ridx (0..$#pattern) {
    for my $c ( 0.. $#{$pattern[$ridx]} ) {
        if ( $pattern[$ridx][$c] eq '#' ) {
            push @positions, [$ridx, $c];
        }
    }
}

printf "%2d, %2d\n", @$_ for @positions;

for my $rot (0..3) {
    my $this = rotate( \@big_one, $rot );
    my $matches = 0;

    ROW:
    for my $ii ( 0 .. $#big_one ) {
        COL:
        for my $jj ( 0 .. $#big_one ) {
            ## End of row
            next ROW if $jj+19 > $#big_one;

            for my $pos ( @positions ) {
                next COL if $ii+$pos->[0] > $#big_one;
                next COL if $jj+$pos->[1] > $#big_one;
                next COL if $this->[ $ii+$pos->[0] ][ $jj+$pos->[1] ] eq '.';
            }
            say "Found one";
            $matches++;
            for my $pos ( @positions ) {
                $this->[ $ii+$pos->[0] ][ $jj+$pos->[1] ] = 'O';
            }
        }
    }

    printf "%d  %d\n", $rot, $matches;
    if ( $matches > 0 ) {
        say join("", @$_) for @$this;
        my $squares = grep { $_ eq '#' } map { @$_ } @$this;
        say $squares;
    }
}

sub get_edge {
    my ($tile, $edge) = @_;
    if ( $edge == 0 ) {
        return join "", @{ $tile->[0] };
    }
    if ( $edge == 1 ) {
        return join "", map { $tile->[$_][-1] } 0..$#$tile;
    }
    if ( $edge == 2 ) {
        return join "", reverse @{ $tile->[-1] };
    }
    if ( $edge == 3 ) {
        return join "", reverse map { $tile->[$_][0] } 0..$#$tile;
    }
    die "NOOOOoooo";
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
    my $l = $#{ $big_one[0] };
    for (0..$l) {
        if ( $_ % 10 == 0 ) {
            print " ";
        }
        print $_%10;
    }
    print "\n";
    for my $ridx ( 0..$#big_one ) {
        print "\n" if $ridx % 10 == 0;
        my $r = $big_one[$ridx];
        for my $idx (0..$#$r) {
            if ( $idx % 10 == 0 ) {
                print " ";
            }
            print $r->[$idx];
        }
        print "\n";
    }
    print "\n";
}


sub get_neighbors_tn {
    my $tn = shift;
    return sort map { $_->[0] } values %{ $tile_lookup{ $tn } };
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

