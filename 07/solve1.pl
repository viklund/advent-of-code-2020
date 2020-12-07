#!/usr/bin/env perl

use strict;
use warnings;

use feature qw/ say /;

local $" = ',';

my %be_in = ();

while (<>) {
    chomp;
    #if (/^(.*?) bags contain ((?:\d+) (.*?) bag,?)+$/) {
    if (/^(.*?) bags contain ((\d+ (.*?) bags?,?)+|no other bags)\.$/) {
        my $container = $1; 
        my @others = grep $_, map { /\d+ (.*?) bags?/ && $1 || /no other bags/ && '' } split ',', $2;
        say "$container (@others)";
        push @{$be_in{$_}}, $container for @others;
    }
    else {
        say "Can't parse $., $_";
    }
}

my @bags = check_bag("shiny gold");
say "DONE";
say for @bags;
say scalar(@bags);

sub check_bag {
    my $bag = shift;

    my @can_be;
    for my $c ( @{ $be_in{$bag}} ) {
        push @can_be, $c;
        push @can_be, check_bag( $c );
    }
    my %s;
    $s{$_}++ for @can_be;
    return keys %s;
}
