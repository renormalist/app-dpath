#!perl -T

use Test::More 0.88;

BEGIN {
        use_ok( 'App::DPath' );
}

diag( "Testing App::DPath $App::DPath::VERSION, Perl $], $^X" );
done_testing;
