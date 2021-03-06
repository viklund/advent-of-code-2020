#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();
use List::MoreUtils qw( duplicates uniq singleton );
use Data::Dumper;


my %all_food = ();
my %might_contain = ();

while (<>) {
    my ($food, $allergens) = /^(.*?) \(contains (.*?)\)$/;
    my @foods = sort split /\s+/, $food;
    my @aller = sort split /\s*,\s*/, $allergens;

    $all_food{$_}++ for @foods;
    for my $a (@aller) {
        push @{ $might_contain{$a} }, [ @foods ];
    }
}

my %short_list;
for my $a (keys %might_contain) {
    my $l = $might_contain{$a};
    my @s = @{ $l->[0] };
    for my $idx (1..$#$l) {
        my @n = duplicates @s, @{ $l->[$idx] };
        @s = @n;
    }
    $short_list{$a} = \@s;
}

my @possibly_allergens = uniq map { @$_ } values %short_list;

my @none = singleton @possibly_allergens, keys %all_food;

my $s = 0;
$s += $all_food{$_} for @none;
say $s;

