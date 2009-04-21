package App::DPath;

use App::Cmd::Setup -app;

our $VERSION = '0.01';

sub default_command { "search" }

1;


=head1 NAME

App::DPath - Tool "dpath" for Data::DPath

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

  $ dpath --in=/etc/interesting/cfg.yml '//some[2]/hash/key'

=head1 FUNCTIONS

This module is meant to be used as cmdline tool. The functions are
described here mostly to keep Pod::Coverage happy.

=head2 default_command

This overwrites the default command to our primary subcommand
C<search>.

=head1 AUTHOR

Steffen Schwigon, C<< <<ss5 at renormalist.net>> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-dpath at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-DPath>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::DPath


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-DPath>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-DPath>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-DPath>

=item * Search CPAN

L<http://search.cpan.org/dist/App-DPath/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Steffen Schwigon, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of App::DPath
