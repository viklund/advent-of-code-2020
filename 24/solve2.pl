#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::MoreUtils qw( minmax );

my %floor;
# 0 means white, 1 means black
$floor{0}{0} = 0;

while (<>) {
    my @pos = (0,0);
    while (m/\G(w|e|nw|ne|sw|se)/g) {
        my $dir = $1;
        given ($dir) {
            when ('w')  { $pos[0]-- }
            when ('e')  { $pos[0]++ }
            when ('nw') { $pos[1]++ }
            when ('se') { $pos[1]-- }
            when ('ne') { $pos[0]++; $pos[1]++ }
            when ('sw') { $pos[0]--; $pos[1]-- }
        }
        $floor{$pos[0]}{$pos[1]} //= 0;
    }
    # Flip
    $floor{$pos[0]}{$pos[1]} = 1 - $floor{$pos[0]}{$pos[1]};
}


step( \%floor ) for 1..100;
my $tiles = grep { $_==1 } map { values %$_ } values %floor;
say $tiles;


sub step {
    my $floor = shift;
    my %count = ();

    for my $x ( keys %$floor ) {
        for my $y ( keys %{$floor->{$x}} ) {
            $count{$_->[0]}{$_->[1]} += $floor->{$x}{$y} for n($x,$y);
        }
    }
    for my $x ( keys %count ) {
        for my $y ( keys %{ $count{$x} } ) {
            my $is_black = $floor->{$x}{$y} // 0;
            my $c = $count{$x}{$y};
            if ( $is_black && ($c==0 || $c>2) ) {
                $floor->{$x}{$y} = 0;
            }
            elsif ( !$is_black && $c==2 ) {
                $floor->{$x}{$y} = 1;
            }
        }
    }
}

sub n {
    my ($x,$y) = @_;

    return ([$x-1, $y],
            [$x+1, $y],
            [$x,   $y+1],
            [$x,   $y-1], 
            [$x+1, $y+1],
            [$x-1, $y-1]);
}

