#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw( min max );

my $world = ();

while (<>) {
    chomp;
    my @c = split //, $_;
    for my $idx ( 0 .. $#c ) {
        if ( $c[$idx] eq '#' ) {
            my $coord = sprintf("%d,%d,%d,%d", $idx,$.,0,0);
            $world->{$coord} = 1;
        }
    }
}

for (1..6) {
    $world = step($world);
}
my $n = grep { exists $world->{$_} } keys %$world;
say "Active $n";

sub print_world {
    my $world = shift;
    my @bounding = get_bounding_box( $world );
    for my $z ( $bounding[2]+1 .. $bounding[5]-1 ) {
        say "z=$z";
        for my $y ( $bounding[1]+1 .. $bounding[4]-1 ) {
            for my $x ( $bounding[0]+1 .. $bounding[3]-1 ) {
                if ( exists $world->{ "$x,$y,$z" } ) {
                    print "#";
                }
                else {
                    print '.';
                }
            }
            print "   ";
            for my $x ( $bounding[0]+1 .. $bounding[3]-1 ) {
                printf "  %2d,%2d", $x, $y;
            }
            print "\n";
        }
        print "\n";
    }
}

sub step {
    my $world = shift;
    my $new_world = {};

    my @bounding = get_bounding_box( $world );
    for my $x ( $bounding[0] .. $bounding[4] ) {
        for my $y ( $bounding[1] .. $bounding[5] ) {
            for my $z ( $bounding[2] .. $bounding[6] ) {
                for my $w ( $bounding[3] .. $bounding[7] ) {
                    my $c = "$x,$y,$z,$w";

                    my @n = get_neighbours( $c );
                    my @a = grep { exists $world->{$_} } @n;

                    if ( exists $world->{$c} && (@a == 2 || @a == 3) ) {
                        $new_world->{$c} = 1;
                    }
                    elsif ( !exists $world->{$c} && @a == 3 ) {
                        $new_world->{$c} = 1;
                    }
                }
            }
        }
    }
    return $new_world;
}

sub get_bounding_box {
    my $w = shift;

    my @coords = map { [split /,/, $_] } keys %$w;

    my ($xmax) = max map { $_->[0] } @coords;
    my ($ymax) = max map { $_->[1] } @coords;
    my ($zmax) = max map { $_->[2] } @coords;
    my ($wmax) = max map { $_->[3] } @coords;
    my ($xmin) = min map { $_->[0] } @coords;
    my ($ymin) = min map { $_->[1] } @coords;
    my ($zmin) = min map { $_->[2] } @coords;
    my ($wmin) = min map { $_->[3] } @coords;
    
    return ($xmin-1, $ymin-1, $zmin-1, $wmin-1, $xmax+1, $ymax+1, $zmax+1, $wmax+1);
}

sub get_neighbours {
    my $coord = shift;
    my ($x,$y,$z,$w) = split /,/, $coord;

    my @r;
    for my $xd ( 1,0,-1 ) {
        for my $yd ( 1,0,-1 ) {
            for my $zd ( 1,0,-1 ) {
                for my $wd ( 1,0,-1 ) {
                    next if $xd == 0 && $yd == 0 && $zd == 0 && $wd == 0;
                    push @r, join(',', $x+$xd, $y+$yd, $z+$zd, $w+$wd);
                }
            }
        }
    }

    return @r;
}
