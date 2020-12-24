#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();

my %floor;

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
        # 0 means white, 1 means black
    }
    $floor{$pos[0]}{$pos[1]} = 1 - ($floor{$pos[0]}{$pos[1]}//0);
}

my $tiles = grep { $_ } map { values %$_ } values %floor;
say $tiles;
