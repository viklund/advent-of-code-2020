#!/usr/bin/env perl
use strict;
use warnings;

use feature qw/ say /;


my @start = (11,18,0,20,1,7,16);

my $n=1;
my %seen = map { ("$_", $n++) } @start[0 .. $#start-1];

my $l = $start[-1];

while ($n<2020) {
    if (exists $seen{$l}) {
        my $diff = $n - $seen{$l};
        $seen{$l} = $n;
        $l = $diff;
    }
    else {
        $seen{$l} = $n;
        $l = 0;
    }
    $n++;
}

say $l;
