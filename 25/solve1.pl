#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say );

my %cache;

#my $card = 5764801;
#my $door = 17807724;

my $card = 3418282;
my $door = 8719412;

my $card_loop = find($card, 7);
my $door_loop = find($door, 7);

printf "Card: %2d, Door: %2d\n", $card_loop, $door_loop;

say transform_nocache($card, $door_loop);
say transform_nocache($door, $card_loop);

sub find {
    my ($target, $subject) = @_;

    my $i = 0;
    if ( exists $cache{$subject} ) {
        $i = $#{ $cache{$subject} } - 1;
    }
    while (1) {
        $i++;
        printf "$i\n" if $i%1_000_000==0;

        my $v = transform($subject, $i);
        return $i if $v == $target
    }
}

sub transform_nocache {
    my ($subject, $loop_size) = @_;

    my $value = 1;
    for (1 .. $loop_size) {
        $value = ( $value * $subject ) % 20201227;
    }
    return $value;
}

sub transform {
    my ($subject, $loop_size) = @_;

    if (exists $cache{$subject}[$loop_size]) {
        return $cache{$subject}[$loop_size];
    }
    $cache{$subject}[0] = 1;

    my $l = $cache{$subject};

    for ($#$l+1 .. $loop_size) {
        $l->[$_] = ($l->[$_-1] * $subject) % 20201227;
    }

    return $l->[$loop_size];
}
