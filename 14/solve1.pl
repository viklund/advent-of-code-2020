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
    $memory{$addr} = apply_mask($arg, $mask);
}

say sum(values %memory);

sub apply_mask {
    my ($arg, $mask) = @_;
    my $apply_one = $mask;
    $apply_one =~ s/X/0/g;
    $apply_one = oct("0b$apply_one");

    my $filter = $mask;
    $filter =~ s/X/1/g;
    $filter = oct("0b$filter");

    my $value = $arg & $filter;
    $value = $value | (0xFFFFFFFFF & $apply_one);
    return $value;
}
