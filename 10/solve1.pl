#!/usr/bin/env perl
use strict;
use warnings;

use feature qw/ say /;

my @adapters;

while (<>) {
    chomp;
    push @adapters, $_;
}

@adapters = sort { $a <=> $b } @adapters;

my $c = 0;
my %jumps = ();
for my $a ( @adapters ) {
    $jumps{ $a - $c }++;
    $c = $a;
}

say "$_: $jumps{$_}" for keys %jumps;
