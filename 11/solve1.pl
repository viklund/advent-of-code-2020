#!/usr/bin/env perl
use strict;
use warnings;

use feature qw( say );


my ($map, $R, $C);
while (<>) {
    chomp;
    push @$map, [split //, $_];
}

$R = $#$map;
$C = $#{ $map->[0] };

show($map);
my $new = simulate($map);

show($new);

my $occ = grep { $_ eq '#' } map { @$_ } @$new;

say $occ;


sub simulate {
    my $m = shift;
    
    my $it = 0;
    while (1) {
        say "$it" if $it++%10 == 0;
        my ($new, $c) = step($m);
        if ( $c == 0 ) {
            return $new;
        }
        $m = $new;
    }
}
        

sub step {
    my $in = shift;
    my $out = [];
    my $changes = 0;
    for my $ii ( 0..$R ) {
        for my $jj ( 0..$C ) {
            if ( $in->[$ii][$jj] eq '.' ) {
                $out->[$ii][$jj] = '.';
                next;
            }
            my $c = count_adj($in, $ii, $jj);
            if ( $c == 0 && $in->[$ii][$jj] eq 'L' ) {
                $out->[$ii][$jj] = '#';
                $changes++;
                next;
            }
            if ( $c >= 4 && $in->[$ii][$jj] eq '#' ) {
                $out->[$ii][$jj] = 'L';
                $changes++;
                next;
            }
            $out->[$ii][$jj] = $in->[$ii][$jj];
        }
    }
    return ($out, $changes);
}

sub show {
    print("\n");
    my $in = shift;
    for my $ii (0..$R) {
        say @{ $in->[$ii] };
    }
}

sub count_adj {
    my ($m, $ii, $jj) = @_;
    my $c = 0;

    $c++ if $ii>0 && $jj>0 && $m->[$ii-1][$jj-1] eq '#';
    $c++ if $ii>0 && $m->[$ii-1][$jj] eq '#';
    $c++ if $ii>0 && $jj<$C && $m->[$ii-1][$jj+1] eq '#';

    $c++ if $jj>0 && $m->[$ii][$jj-1] eq '#';
    $c++ if $jj<$C && $m->[$ii][$jj+1] eq '#';

    $c++ if $ii<$R && $jj>0 && $m->[$ii+1][$jj-1] eq '#';
    $c++ if $ii<$R && $m->[$ii+1][$jj] eq '#';
    $c++ if $ii<$R && $jj<$C && $m->[$ii+1][$jj+1] eq '#';

    return $c;
}
