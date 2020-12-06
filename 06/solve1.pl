#!/usr/bin/env perl

use strict;
use warnings;

use feature qw/ say /;

local $/="\n\n";

my $sum = 0;
while (<>) {
    s/\s*//g;

    my %c;
    $c{$_}++ for split //, $_;
    $sum += keys %c;
}
say $sum;
