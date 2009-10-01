#! /usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Test::More tests => 16;
use Test::Deep;
use JSON;
use YAML::Syck;
use Config::General;
use Data::Structure::Util 'unbless';

BEGIN {
	use_ok( 'App::DPath' );
}

sub check {
        my ($intype, $outtype, $path, $expected, $just_diag) = @_;

        $path       ||= '//lines//description[ value =~ m(use Data::DPath) ]/../_children//data//name[ value eq "Hash two"]/../value';
        $expected   ||= [ "2" ];
        my $program   = "$^X -Ilib script/dpath";
        #my $unblessed = $outtype eq "json" ? "_unblessed" : "";
        my $infile    = "t/testdata.$intype";
        my $cmd       = "$program -i $intype -o $outtype '$path' $infile";
        #diag $cmd;
        my $output    = `$cmd`;

        my $result;
        if ($outtype eq "json")
        {
                $result = JSON::from_json(unbless $output);
        }
        elsif ($outtype eq "yaml") {
                $result = YAML::Syck::Load($output);
        }
        elsif ($outtype eq "cfggeneral") {
                my %data = Config::General->new(-String => $output)->getall;
                $result = \%data;
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
# XML <-> data mapping is somewhat artificial, so another path is needed
check (qw(xml dumper), '//description[ value =~ m(use Data::DPath) ]/../_children//data//Hash two/value');
check (qw(ini dumper), '//description[ value =~ m(use Data::DPath) ]/../number', [ "1" ]);
check (qw(ini json),   '//description[ value =~ m(use Data::DPath) ]/../number', [ "1" ]);
check (qw(ini yaml),   '//description[ value =~ m(use Data::DPath) ]/../number', [ "1" ]);

# Config::General is also somewhat special
check (qw(cfggeneral json), '/etc/base', [ "/usr" ]);
check (qw(cfggeneral json), '//home', [ "/usr/home/max" ]);
check (qw(cfggeneral json), '//mono//bl', [ 2 ]);
check (qw(cfggeneral json), '//log', [ "/usr/log/logfile" ]);

check (qw(cfggeneral yaml), '/etc/base', [ "/usr" ]);
check (qw(cfggeneral yaml), '//home', [ "/usr/home/max" ]);
check (qw(cfggeneral yaml), '//mono//bl', [ 2 ]);
check (qw(cfggeneral yaml), '//log', [ "/usr/log/logfile" ]);
