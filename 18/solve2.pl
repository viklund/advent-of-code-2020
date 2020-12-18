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
    for (@tokens) {
        when (/\d+/) {
            if (@terms && $terms[-1] =~ /\+/) {
                pop @terms;
                my $o = pop @terms;
                push @terms, $o + $_;
                next TOKEN;
            }
            if (@terms && $terms[-1] =~ /\*/) {
                push @terms, $_;
                next TOKEN;
            }
            push @terms, $_;
        }
        when ([qw/ + * ( /]) {
            push @terms, $_;
        }
        when ( ')' ) {
            my $r = pop @terms;
            INNER:
            while ( $terms[-1] ne '(' ) {
                my $t = pop @terms;
                if ( $t eq '*' ) {
                    $r *= pop @terms;
                    next INNER;
                }
                else {
                    die "WTF\n";
                }
            }

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
    }
    die "$. (@terms)\n" if ( @terms != 1 );
    $tot += $terms[0];
}

say $tot;
