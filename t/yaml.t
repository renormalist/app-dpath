#! /usr/bin/env perl

use strict;
use warnings;
use Test::More 0.88;

diag qq{Ignore the following YAML parsing errors - that's what we test...};

my $program    = "$^X -Ilib bin/dpath";
my $infile     = "t/example.yaml10";
my $res_yaml11 = `$program -i yaml   -o yaml / $infile`;
my $res_yaml10 = `$program -i yaml10 -o yaml / $infile`;

unlike($res_yaml11, qr/Contourscount:/, "yaml non-syck parsing expectedly fails");
like($res_yaml10,   qr/Contourscount:/, "yaml syck parsing succeeds");

done_testing;
