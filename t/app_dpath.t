#! /usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Test::More tests => 7;
use Test::Deep;
use JSON;
use YAML::Syck;

BEGIN {
	use_ok( 'App::DPath' );
}

sub check {
        my ($intype, $outtype, $path, $expected, $just_diag) = @_;

        $path       ||= '//lines//description[ value =~ m(use Data::DPath) ]/../_children//data//name[ value eq "Hash two"]/../value';
        $expected   ||= [ "2" ];
        my $program   = "$^X -Ilib script/dpath";
        my $unblessed = $outtype eq "json" ? "_unblessed" : "";
        my $infile    = "t/some_tap$unblessed.$intype";
        my $cmd       = "$program -i $intype -o $outtype '$path' $infile";
        #diag $cmd;
        my $output    = `$cmd`;

        my $result;
        if ($outtype eq "json")
        {
                $result = JSON::from_json($output);
        }
        elsif ($outtype eq "yaml") {
                $result = YAML::Syck::Load($output);
        }
        elsif ($outtype eq "dumper")
        {
                eval "\$result = my $output";
        }
        if ($just_diag) {
                diag Dumper($result);
        } else {
                cmp_deeply $result, $expected, "$intype - dpath - $outtype";
        }
}

check (qw(yaml json));
check (qw(yaml dumper));
check (qw(json dumper));
check (qw(ini dumper), '//description[ value =~ m(use Data::DPath) ]/../number', [ "1" ]);
check (qw(ini json),   '//description[ value =~ m(use Data::DPath) ]/../number', [ "1" ]);
check (qw(ini yaml),   '//description[ value =~ m(use Data::DPath) ]/../number', [ "1" ]);
