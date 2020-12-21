#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();
use List::MoreUtils qw( duplicates uniq singleton );
use Data::Dumper;

#my @lists;

my %might_contain = ();

while (<>) {
    my ($food, $allergens) = /^(.*?) \(contains (.*?)\)$/;
    my @foods = sort split /\s+/, $food;
    my @aller = sort split /\s*,\s*/, $allergens;

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


while (1) {
    my $change = 0;
    my @singletons =  grep { @{$short_list{$_}} == 1 } keys %short_list;
    for my $allergen (keys %short_list) {
        for my $s (@singletons) {
            next if $s eq $allergen;
            my $ingredient = $short_list{$s}[0];
            my @ing = grep { $_ ne $ingredient } @{ $short_list{$allergen} };
            if ( @ing < @{ $short_list{$allergen} } ) {
                $change++;
            }
            $short_list{$allergen} = \@ing;
        }
    }
    last unless $change;
}

say join(',', map { $short_list{$_}[0] } sort keys %short_list);
