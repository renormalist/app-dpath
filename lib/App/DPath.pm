package App::DPath;
# ABSTRACT: Cmdline tool around Data::DPath

use App::Cmd::Setup -app;

use 5.008; # Data::DPath requires it
use strict;
use warnings;

1;

__END__

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

=head2 Input formats

The following B<input formats> are allowed, with their according
modules used to convert the input into a data structure:

 yaml   - YAML::Syck (default)
 json   - JSON
 xml    - XML::Simple
 ini    - Config::INI::Serializer
 dumper - Data::Dumper (including the leading $VAR1 variable assignment)
 tap    - TAP::DOM

=head2 Output formats

The following B<output formats> are allowed:

 yaml   - YAML::Syck (default)
 json   - JSON
 xml    - XML::Simple
 ini    - Config::INI::Serializer
 dumper - Data::Dumper (including the leading $VAR1 variable assignment)
 flat   - pragmatic flat output for typical unixish cmdline usage

For more information about the DPath syntax, see
L<Data::DPath|Data::DPath>.

=head2 The 'flat' output format

The C<flat> output format is meant to support typical unixish command
line uses. It is not a strong serialization format but works well for
simple values nested max 2 levels.

Output looks like this:

=head3 Plain values

 Affe
 Tiger
 Birne

=head3 Outer hashes

One outer key per line, key at the beginning of line with a colon
(C<:>), inner values separated by semicolon C<;>:

=head4 inner scalars:

 coolness:big
 size:average
 Eric:The flat one from the 90s

=head4 inner hashes:

Tuples of C<key=value> separated by semicolon C<;>:

 Affe:coolness=big;size=average
 Zomtec:coolness=bit anachronistic;size=average

=head4 inner arrays:

Values separated by semicolon C<;>:

 Birne:bissel;hinterher;manchmal

=head3 Outer arrays

One entry per line, entries separated by semicolon C<;>:

=head4 inner scalars:

 single report string
 foo
 bar
 baz

=head4 inner hashes:

Tuples of C<key=value> separated by semicolon C<;>:

 Affe=amazing moves in the jungle;Zomtec=slow talking speed;Birne=unexpected in many respects

=head4 inner arrays:

Entries separated by semicolon C<;>:

 line A-1;line A-2;line A-3;line A-4;line A-5
 line B-1;line B-2;line B-3;line B-4
 line C-1;line C-2;line C-3

=head3 Additional markup for arrays:

 --fb            ... use [brackets] around outer arrays
 --fi            ... prefix outer array lines with index
 --separator=;   ... use given separator between array entries (defaults to ";")

Such additional markup lets outer arrays look like this:

 0:[line A-1;line A-2;line A-3;line A-4;line A-5]
 1:[line B-1;line B-2;line B-3;line B-4]
 2:[line C-1;line C-2;line C-3]
 3:[Affe=amazing moves in the jungle;Zomtec=slow talking speed;Birne=unexpected in many respects]
 4:[single report string]

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

=cut
