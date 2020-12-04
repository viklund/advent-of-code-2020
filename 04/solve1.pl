#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say ) ;

my @req = qw/ byr iyr eyr hgt hcl ecl pid/;
my @opt = qw/ cid /;

my $correct;
my %found = ();
while (<>) {
    chomp;
    if (/^\s*$/) {
        my $f = 0;
        for (@req) {
            $f++ if exists $found{$_};
        }
        $correct++ if $f==7;
        %found = ();
        next;
    }
    $found{$_}++ for map { /^(.*?):(.*?)/; $1 } split;
}

my $f = 0;
for (@req) {
    $f++ if exists $found{$_};
}
$correct++ if $f==7;

say $correct;
