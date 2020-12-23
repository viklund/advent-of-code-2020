#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::MoreUtils qw( any firstidx );

my @cups = split //, '157623984';
#my @cups = split //, '389125467';


for (1..100) {
    move();
}

ans();
say @cups[1..$#cups];


sub move {
    my $cur = $cups[0];
    my @move = splice @cups, 1, 3;
    my $dest = ($cur-2)%9 + 1;
    while ( ! any { $_ == $dest } @cups ) {
        $dest = ($dest-2)%9 + 1;
    }
    my $desti = 1 + firstidx { $_ == $dest } @cups;
    splice @cups, $desti, 0, @move;
    push @cups, shift @cups;
}

sub ans {
    while ($cups[0] != 1) {
        push @cups, shift @cups;
    }
}
