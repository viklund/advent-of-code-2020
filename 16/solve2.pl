#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();

use Data::Dumper;

my %field_rules = ();
my %field_assign = ();

my %allowed = ();
my $mode;
my $myticket;

TICKET:
while (<>) {
    if (/^(.*?): (\d+)-(\d+) or (\d+)-(\d+)$/) {
        my ($f, $s1,$e1,$s2,$e2) = ($1, $2,$3,$4,$5);

        $allowed{$_}++ for $s1..$e1;
        $allowed{$_}++ for $s2..$e2;

        $field_rules{$f}{$_}++ for $s1..$e1;
        $field_rules{$f}{$_}++ for $s2..$e2;

        $field_assign{$f} = { map { ($_,1) } 0..19 }; # There are 20 fields
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
        }
        chomp;
        my @numbers = split /,/, $_;
        for (@numbers) {
            if (! exists $allowed{$_}) {
                next TICKET;
            }
        }
        for my $idx (0..$#numbers) {
            my $number = $numbers[$idx];
            my @fields = grep { exists $field_assign{$_}{$idx} } keys %field_assign;

            for my $field (@fields) {
                if ( ! exists $field_rules{$field}{$number} ) {
                    delete $field_assign{$field}{$idx};
                }
            }
        }
        next;
    }
    die "WTF: $_";
}

my $changed = 1;
while ($changed) {
    $changed = '';
    my @ones = grep { keys %{$field_assign{$_}} == 1 } keys %field_assign;
    for my $k ( @ones ) {
        my ($ass) = keys %{$field_assign{$k}};
        for my $field ( keys %field_assign ) {
            next if $field eq $k;
            if ( exists $field_assign{$field}{$ass} ) {
                $changed++;
                delete $field_assign{$field}{$ass};
            }
        }
    }
}

my $v = 1;
my @ticket = split /,/, $myticket;
for my $k ( keys %field_assign ) {
    next unless $k =~ /^departure/;
    my ($idx) = keys %{ $field_assign{$k} };
    $v *= $ticket[$idx];
}

say $v;
