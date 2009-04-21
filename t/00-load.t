#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'App::DPath' );
}

diag( "Testing App::DPath $App::DPath::VERSION, Perl $], $^X" );
