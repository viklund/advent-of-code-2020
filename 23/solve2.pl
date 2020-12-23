#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say );

my $MAX = 1_000_000;
my @cups = split //, '157623984';
#my @cups = split //, '389125467';

my %all = ();
my $first_cup = {
    value => 1,
    next => undef,
    prev => undef,
};
$all{1} = $first_cup;

my $p = $first_cup;
for my $v ( @cups[1..$#cups], 10..1_000_000 ) {
    my $c = {
        next => undef,
        prev => $p,
        value => $v,
    };
    $p->{next} = $c;
    $all{$v} = $c;
    $p = $c;
}

$first_cup->{prev} = $p;
$p->{next} = $first_cup;

my $start = $first_cup;
for (1..10_000_000) {
    $start = move( $start );
}

ans2($start);

sub move {
    my $this = shift;

    my $first = $this->{next};
    my $last = $first->{next}{next};

    my %blacklist = map { ($_,1) } ($first->{value}, $first->{next}{value}, $last->{value});

    # Extract node
    my $after = $last->{next};
    $this->{next} = $after;
    $after->{prev} = $this;


    # Insert at new place
    my $dest = ($this->{value}-2) % $MAX + 1;
    while ( exists $blacklist{$dest} ) {
        $dest = ($dest-2)%$MAX + 1;
    }
    my $d = $all{$dest};

    my $a = $d->{next};
    $d->{next} = $first;
    $first->{prev} = $d;

    $last->{next} = $a;
    $a->{prev} = $last;

    return $this->{next};
}

sub ans1 {
    my $this = shift;
    $this = $this->{next} while $this->{value} != 1;

    $this = $this->{next};
    while ( $this->{value} != 1 ) {
        print $this->{value};
        $this = $this->{next};
    }
    print "\n";
}

sub ans2 {
    my $this = shift;
    $this = $this->{next} while $this->{value} != 1;

    say $this->{next}{value} * $this->{next}{next}{value};
}
