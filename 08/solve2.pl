#!/usr/bin/env perl
use strict;
use warnings;

use feature qw/say/;

my @program = ();
while (<>) {
    my ($ins, $arg) = split;
    push @program, [$ins, $arg];
}

my $change = 0;

for my $p (0 .. $#program) {
    my ( $ins, $arg ) = @{ $program[$p] };
    next if ( $ins eq 'acc' );
    say "Trying $p: $ins $arg";
    if ( $ins eq 'nop' ) {
        $program[$p][0] = 'jmp';
        my ($s, $acc) = try();
        if ($s) {
            say $acc;
            exit;
        }
        $program[$p][0] = 'nop';
    }
    if ( $ins eq 'jmp' ) {
        $program[$p][0] = 'nop';
        my ($s, $acc) = try();
        if ($s) {
            say $acc;
            exit;
        }
        $program[$p][0] = 'jmp';
    }
}


sub try {
    my $acc = 0;
    my $p = 0;
    my %seen = ();

    while ( !$seen{$p}++ and $p <= $#program ) {
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
    
    return ($p > $#program, $acc);
}
