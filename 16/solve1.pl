#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();

my %allowed = ();
my $mode;
my $myticket;
my $invalid=0;

while (<>) {
    if (/^(.*?): (\d+)-(\d+) or (\d+)-(\d+)$/) {
        my ($s1,$e1,$s2,$e2) = ($2,$3,$4,$5);
        $allowed{$_}++ for $s1..$e1;
        $allowed{$_}++ for $s2..$e2;
        next;
    }
    next if /^$/;
    if (/^your ticket/) {
        $mode = 'y';
        next;
    }
    if (/^nearby ticket/) {
        $mode = 'n';
        next;
    }
    if (/^[0-9,]+$/) {
        if ($mode eq 'y') {
            $myticket = $_;
            next;
        }
        if ( $mode ne 'n') {
            die "WTF: $_";
        }
        chomp;
        my @numbers = split /,/, $_;
        for (@numbers) {
            if (! exists $allowed{$_}) {
                $invalid += $_;
            }
        }
        next;
    }
    die "WTF: $_";
}

say $invalid;
