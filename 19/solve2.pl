#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say switch );
no warnings "experimental::smartmatch";

use List::Util qw();
use Data::Dumper;

my %rules = ();

while (<>) {
    last if /^\s*$/;

    s/"//g; # Don't need them

    my ($num, $matches) = /^(\d+): (.*)$/;
    my @rules = split /\s*\|\s*/, $matches;

    for my $r (@rules) {
        my @ns = split /\s+/, $r;
        if ( @ns == 1 && $ns[0] =~ /a|b/ ) {
            $rules{$num} = $ns[0];
            next;
        }
        push @{$rules{$num}}, \@ns;
    }
}


my $forty_two = build_regex_from_rules( \%rules, 42 );
my $thirty_one = build_regex_from_rules( \%rules, 31 );

my $regex = $forty_two . '+';
my @ms = ();
for my $num (1..10) { ## it should go to infinity, but 10 "works"
    my $m = sprintf "((%s){%d}(%s){%d})", $forty_two, $num, $thirty_one, $num;
    push @ms, $m;
}

$regex .= '(' . join('|', @ms ) . ')';

$regex = qr/^$regex$/o;
say $regex;

my $matches = 0;
while (<>) {
    chomp;
    if ( $_ =~ $regex ) {
        $matches++;
    }
}
say $matches;

sub build_regex_from_rules {
    my ($rules, $pos) = @_;
    if ( !ref( $rules{$pos} ) ) {
        return $rules{$pos};
    }
    my @subs;
    for my $r ( @{ $rules{$pos} } ) {
        my $sub = join '', map { build_regex_from_rules($rules, $_) } @$r;
        push @subs, "($sub)";
    }
    return '(' . join('|', @subs) . ')';
}
