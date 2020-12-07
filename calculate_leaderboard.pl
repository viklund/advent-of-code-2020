#!/usr/bin/env perl
use strict;
use warnings;

use JSON;
use Data::Dumper;

use Encode;

use feature 'say';

my $contents = '';

while (<>) {
    $contents .= $_;
}
$contents = encode('utf-8', $contents);
my $json = decode_json($contents)->{'members'};


my %all_days;
my %day_times = ();
my $num_contestants = 0;
my @contestants = ();

my %at = ();

for my $m ( values %$json ) {
    $num_contestants++;
    my $name = $m->{name} // $m->{id};
    push @contestants, $name;

    if (!exists $m->{completion_day_level}) {
        next;
    }

    my $c = $m->{completion_day_level};
    for my $day ( keys %$c ) {
        $all_days{$day}++;
        my %v = %{$c->{$day} // {}};
        if (exists $v{1}) {
            $at{$v{1}{get_star_ts}} = [$name, "$day-1"];
        }
        if (exists $v{2}) {
            $at{$v{2}{get_star_ts}} = [$name, "$day-2"];
        }
    }
}

my @scores;
my %score_of;
my %stars_of;
my %day_points = map { ("$_-1" => $num_contestants, "$_-2" => $num_contestants) } keys %all_days;
#$day_points{"1-1"} = 0;
#$day_points{"1-2"} = 0;

@contestants = sort @contestants;

open my $POINTS, '>', 'chart-points.tsv' or die;
open my $STARS,  '>', 'chart-stars.tsv' or die;
say $POINTS join "\t", "ts", @contestants;
say $STARS  join "\t", "ts", @contestants;

for my $ts ( sort { $a <=> $b } keys %at ) {
    #printf "%10s  %-20.20s  %2d\n", $ts, $at{$ts}[0], $at{$ts}[1];
    if ( ! exists $at{ $ts - 1 } ) {
        say $POINTS join "\t", $ts-1, map { $score_of{$_} // 0 } @contestants;
        say $STARS  join "\t", $ts-1, map { $stars_of{$_} // 0 } @contestants;
    }
    $score_of{$at{$ts}[0]} += $day_points{$at{$ts}[1]};
    $stars_of{$at{$ts}[0]} += 1;

    if (--$day_points{$at{$ts}[1]} < 0) {
        $day_points{$at{$ts}[1]} = 0;
    }

    say $POINTS join "\t", $ts, map { $score_of{$_} // 0 } @contestants;
    say $STARS  join "\t", $ts, map { $stars_of{$_} // 0 } @contestants;
}

#say Dumper( \%at );

__END__
#say Dumper( \%day_times );
say $num_contestants;
my %points = ();
for my $day ( keys %day_times ) {
    my @ranking = sort { $day_times{$day}{$a} <=> $day_times{$day}{$b} } keys %{$day_times{$day}};
    for my $i (0..$#ranking) {
    }
    say "$day\t", join("\t", @ranking);
}

