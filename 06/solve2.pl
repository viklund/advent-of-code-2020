#!/usr/bin/env perl

use strict;
use warnings;

use feature qw/ say /;

local $/="\n\n";

my $sum = 0;
while (<>) {
    chomp;
    my $n = split "\n", $_;
    s/\s*//g;

    my %c;
    $c{$_}++ for split //, $_;
    $sum += grep { $c{$_} == $n } keys %c;
}
say $sum;
