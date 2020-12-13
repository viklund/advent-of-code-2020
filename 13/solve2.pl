#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say );

my $now = <>;
chomp($now);

$now = 0;

my $buses = <>;
chomp $buses;
my @buses = split ',', $buses;

my %idx_of = map { ($buses[$_], $_) } grep /^[^x]/, 0..$#buses;
my %departing = map { ($_,0) } grep /^[^x]/, @buses;

@buses = grep /^[^x]/, @buses;

my $it=0;
my $step = $buses[$it];

for my $bus ( @buses[1..$#buses] ) {
    printf "%12d (%12d) %5d (%2d)\n", $it, $step, $bus, $idx_of{$bus};
    while ( ($it + $idx_of{$bus})%$bus != 0 ) {
        $it += $step;
    }
    $step *= $bus;
}

my $bus = $buses[-1];
printf "%12d (%12d) %5d (%2d)\n", $it, $step, $bus, $idx_of{$bus};

say " -> ", $it;
