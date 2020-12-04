#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say ) ;

use Data::Dumper;

my @req = qw/ byr iyr eyr hgt hcl ecl pid/;
my @opt = qw/ cid /;

my %check = (
    byr => sub { my $d = shift; return $d =~ /^\d{4}$/ && $d >= 1920 && $d <= 2002 },
    iyr => sub { my $d = shift; return $d =~ /^\d{4}$/ && $d >= 2010 && $d <= 2020 },
    eyr => sub { my $d = shift; return $d =~ /^\d{4}$/ && $d >= 2020 && $d <= 2030 },
    hgt => sub { my $d = shift; return unless $d =~ /^(\d+)(cm|in)$/; 
        if ( $2 eq 'cm' ) {
            return $1 >=150 && $1<=193;
        }
        return $1>=59 && $1<=76
    },
    hcl => sub { my $d = shift; return $d =~ /^#[0-9a-f]{6}$/ },
    ecl => sub { my $d = shift; return $d =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/ },
    pid => sub { my $d = shift; return $d =~ /^\d{9}$/ },
);

my $correct=0;
my %p = ();
while (<>) {
    chomp;
    if (/^\s*$/) {
        say Dumper(\%p);
        $correct++ if check_passport( \%p );
        %p = ();
        next;
    }
    $p{$_->[0]} = $_->[1] for map { /^(.*?):(.*?)$/; [$1, $2]} split;
}

if ( %p ) {
    say Dumper(\%p);
    $correct++ if check_passport( \%p );
}

say $correct;

sub check_passport {
    my $p = shift;
    for my $field ( keys %check ) {
         if ( ! exists $p->{$field} ) {
             say  "INV: Can't find $field";
             return '';
         }
         if ( ! $check{$field}->($p->{$field}) ) {
             say  "INV: $field invalid";
             return '';
         }
    }
    say "VALID";
    return 1;
}
