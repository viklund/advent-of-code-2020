#!/usr/bin/env perl
use strict;
use warnings;

use feature 'say';

my @map;
while (<>) {
    chomp;
    push @map, [split //, $_];
}

my $pos = 0;
my $trees = 0;
shift @map;
for my $row (@map) {
    $pos += 3;
    if ($pos > $#$row) {
        $pos %= @$row;
    }
    if ($row->[$pos] eq '#') {
        $row->[$pos] = 'X';
        $trees++;
    }
    else {
        $row->[$pos] = 'O';
    }
    say join '', @$row;
}

say $trees;
