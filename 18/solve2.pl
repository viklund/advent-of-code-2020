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
    #$_ = "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2";
    #say;
    chomp;
    s/\(/( /g;
    s/\)/ )/g;

    my @terms;
    my @tokens = split /\s+/, "( $_ )";
    TOKEN:
    for my $token (@tokens) {
        #say "$token :: @terms";
        if ($token =~ /\d+/) {
            if (@terms && $terms[-1] =~ /\+/) {
                pop @terms;
                my $o = pop @terms;
                push @terms, $o + $token;
                next TOKEN;
            }
            if (@terms && $terms[-1] =~ /\*/) {
                push @terms, $token;
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
            my $r = pop @terms;
            INNER:
            while (1) {
                #say " -> $r :: @terms";
                if ( $terms[-1] eq '(' ) {
                    pop @terms;
                    if (@terms == 0 ) {
                        push @terms, $r;
                        next TOKEN;
                    }
                    if ( $terms[-1] eq '+' ) {
                        pop @terms;
                        $r += pop @terms;
                    }
                    push @terms, $r;
                    next TOKEN;
                }
                if ( $terms[-1] eq '*' ) {
                    pop @terms;
                    $r *= pop @terms;
                }
                else {
                    die "WTF\n";
                }
            }
        }
    }
    die "$. (@terms)\n" if ( @terms != 1 );
    $tot += $terms[0];
}

say $tot;
