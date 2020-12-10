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

my $device = $adapters[-1]+3;
push @adapters, $device;

my %cache = ();

say num(0,0);
my $i=0;

sub num {
    my ($c, $s) = @_;
    $i++;
    printf "Checking %d  (%d)\n", $c, $i if $c < 90;
    if ($s == $#adapters) {
        return 1;
    }

    my $num = 0;
    while ( $adapters[$s] <= $c+3 ) {
        if ( ! exists $cache{$s} ) {
            $cache{$s} =  num($adapters[$s], $s+1);
        }
        $num += $cache{$s};
        $s++;
    }
    return $num;
}
