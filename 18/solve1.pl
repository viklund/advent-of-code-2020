#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();

my $tot = 0;

while (<>) {
    #$_ = "1 + 2 * 3 + 4 * 5 + 6";
    #$_ = "1 + (2 * 3) + (4 * (5 + 6))";
    chomp;
    s/\(/( /g;
    s/\)/ )/g;

    my @terms;
    TOKEN:
    for my $token (split) {
        if ($token =~ /\d+/) {
            if (@terms && $terms[-1] =~ /\+/) {
                pop @terms;
                my $o = pop @terms;
                push @terms, $o + $token;
                next TOKEN;
            }
            if (@terms && $terms[-1] =~ /\*/) {
                pop @terms;
                my $o = pop @terms;
                push @terms, $o * $token;
                next TOKEN;
            }
            push @terms, $token;
        }
        if ( $token =~ /\+|\*/ ) {
            push @terms, $token;
        }
        if ( $token =~ /\(/) {
            push @terms, $token;
            next TOKEN;
        }
        if ($token =~ /\)/) {
            $token = pop @terms;
            pop @terms;
            redo TOKEN;
        }
    }
    die "$. (@terms)\n" if ( @terms != 1 );
    $tot += $terms[0];
}

say $tot;
