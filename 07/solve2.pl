#!/usr/bin/env perl

use strict;
use warnings;

use feature qw/ say /;

local $" = ',';

my %contain = ();

while (<>) {
    chomp;
    #if (/^(.*?) bags contain ((?:\d+) (.*?) bag,?)+$/) {
    if (/^(.*?) bags contain ((\d+ (.*?) bags?,?)+|no other bags)\.$/) {
        my $container = $1; 
        my @others = grep $_, map { /(\d+ .*?) bags?/ && $1 || /no other bags/ && '' } split ',', $2;
        say "$container (@others)";
        push @{$contain{$container}}, $_ for @others;
    }
    else {
        say "Can't parse $., $_";
    }
}

my $t = check_bag("shiny gold");
say "DONE";
say $t;

sub check_bag {
    my $bag = shift;

    say "checking $bag";
    my $t = 0;
    for my $c ( @{ $contain{$bag}} ) {
        my ($num, $o) = $c =~ /(\d+) (.*?)$/;
        say " -> $num, $o";
        $t += $num;
        $t += $num*check_bag( $o );
    }
    return $t;
}
