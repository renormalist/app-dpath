package App::DPath;

use App::Cmd::Setup -app;

use 5.010; # Data::DPath requires it anyway
use strict;
use warnings;

our $VERSION = '0.02';

1;


=head1 NAME

App::DPath - Cmdline tool around Data::DPath

=head1 SYNOPSIS

This module provides a cmdline tool around Data::DPath.

Query some input data with a DPath to stdout.

Default data format (in and out) is YAML, other formats can be
specified.

  $ dpath '//some/dpath' data.yaml

Use it as filter:

  $ dpath '//some/dpath' < data.yaml > result.yaml
  $ cat data.yaml | dpath '//some/dpath' > result.yaml
  $ cat data.yaml | dpath '//path1' | dpath '//path2' | dpath '//path3'

Specify that output is YAML(default), JSON, XML or Data::Dumper:

  $ dpath -o yaml   '//some/dpath' data.yaml
  $ dpath -o json   '//some/dpath' data.yaml
  $ dpath -o xml    '//some/dpath' data.yaml
  $ dpath -o dumper '//some/dpath' data.yaml

Input is JSON:

  $ dpath -i json '//some/dpath' data.json

Input is XML:

  $ dpath -i xml '//some/dpath' data.xml

Input is INI:

  $ dpath -i ini '//some/dpath' data.ini

Input is TAP:

  $ dpath -i tap '//some/dpath' data.tap
  $ perl t/some_test.t | dpath -i tap '//tests_planned'

Input is JSON, Output is Data::Dumper:

  $ dpath -i json -o dumper '//some/dpath' data.json

The following B<input formats> are allowed, with their according
modules used to convert the input into a data structure:

 yaml   - YAML::Syck (default)
 json   - JSON
 xml    - XML::Simple
 ini    - Config::INI::Reader
 dumper - Data::Dumper (including the leading $VAR1 variable assignment)
 tap    - TAP::DOM

The following B<output formats> are allowed:

 yaml   - YAML::Syck (default)
 json   - JSON
 xml    - XML::Simple
 ini    - Config::INI::Writer
 dumper - Data::Dumper (including the leading $VAR1 variable assignment)

For more information about the DPath syntax, see
L<Data::DPath|Data::DPath>.


=head1 DEFAULT COMMAND CHEATING

The C<dpath> tool is based on L<App::Cmd> which is using sub
commands. All the above examples use the default subcommand C<search>
which is silently inserted into the argument/options list if no
subcommand is given.

So instead of

  $ dpath -i json -o dumper data.json

you can also write

  $ dpath search -i json -o dumper data.json

Other available subcommands are C<help> and C<commands>.

The built in help always fully refers to subcommands.


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


=head1 COPYRIGHT & LICENSE

Copyright 2009 Steffen Schwigon, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of App::DPath
