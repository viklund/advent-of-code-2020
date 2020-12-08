#!/usr/bin/env perl
use strict;
use warnings;

use feature qw/say/;

my @program = ();
while (<>) {
    my ($ins, $arg) = split;
    push @program, [$ins, $arg];
}

my $acc = 0;
my $p = 0;

my %seen = ();

while ( !$seen{$p}++ ) {
    my ( $ins, $arg ) = @{ $program[$p] };
    if ( $ins eq 'jmp' ) {
        $p += $arg;
        next;
    }
    if ( $ins eq 'acc' ) {
        $acc += $arg;
    }
    $p+=1;
}

say $acc;
