#!/usr/bin/env perl
use strict;
use warnings;

use feature qw/ say /;

use List::Util qw/ sum /;
no warnings 'portable';

my $mask;
my %memory;

while (<>) {
    my ($op, $arg) = /^(\S+)\s=\s(\S+)$/;
    if ( $op eq 'mask' ) {
        $mask = $arg;
        next;
    }
    my ($addr) = $op =~ /^mem\[(\d+)\]/;
    #say "Setting $addr, $mask, $arg";
    set_memory($addr, $mask, $arg);
}

say sum(values %memory);

sub set_memory {
    my ($addr, $mask, $arg) = @_;

    # First add the `1` bits to the value
    my $apply = $mask =~ s/X/0/gr;
    $apply = oct("0b$apply");
    $addr |= $apply;

    my $i = 0;
    my @bits = map { oct(sprintf("0b%s1%s", '0'x$_->[0], '0'x(35-$_->[0]))) } grep { $_->[1] eq 'X' } map { [$i++, $_] } split //, $mask;

    # Now go through all combination of masks
    my $combs = 2**@bits;
    for my $c (0..$combs-1) {
        my @on  = grep {   (2**$_) & $c  } 0..$#bits;
        my @off = grep { !((2**$_) & $c) } 0..$#bits;

        my $on_value = 0;
        $on_value |= $_ for @bits[@on];
        my $off_value = 0;
        $off_value |= $_ for @bits[@off];

        my $a = $addr;
        $a = $a | $on_value;
        $a = ($a | $off_value) - $off_value;

        $memory{ $a } = $arg;
    }
}
