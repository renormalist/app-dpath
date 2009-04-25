package App::DPath::Command::search;

use App::DPath -command;

use strict;
use warnings;

use Data::DPath 'dpath';

sub opt_spec {
        return (
                [ "intype|i=s",   "input format, [yaml(default), json, dumper, ini, tap]"  ],
                [ "outtype|o=s",  "output format, [yaml(default), json, dumper]" ],
               );
}

sub validate_args {
    my ($self, $opt, $args) = @_;

    if (not $args->[0]) {
            print STDERR "Please specify a dpath.\n";
            exit 1;
    }
}

sub read_in {
        my ($self, $opt, $args, $file) = @_;

        my $intype  = $opt->{intype}  || 'yaml';
        my $data;
        my $filecontent;
        {
                local $/;
                if ($file eq '-') {
                        $filecontent = <STDIN>;
                }
                else
                {
                        open (my $FH, "<", $file) or die "Cannot open file $file";
                        $filecontent = <$FH>;
                        close $FH;
                }
        }

        if ($filecontent !~ /[^\s\t\r\n]/ms) {
                print STDERR "Please provide some input data.\n";
                exit 1;
        }

        if ($intype eq "yaml") {
                require YAML::Syck;
                $data = YAML::Syck::Load($filecontent);
        }
        elsif ($intype eq "json") {
                require JSON;
                $data = JSON::decode_json($filecontent);
        }
        elsif ($intype eq "ini") {
                require Config::INI::Reader;
                $data = Config::INI::Reader->read_string($filecontent);
        }
        elsif ($intype eq "dumper") {
                eval '$data = my '.$filecontent;
        }
        elsif ($intype eq "tap") {
                require TAP::DOM;
                $data = new TAP::DOM( tap => $filecontent );
        }
        else
        {
                die "Unrecognized input type: $intype";
        }
        return $data;
}

sub match {
        my ($self, $opt, $args, $data, $path) = @_;

        if (not $data) {
                print STDERR "Please provide proper input data.\n";
                exit 1;
        }

        my @resultlist = dpath($path)->match($data);
        return \@resultlist;
}

sub write_out {
    my ($self, $opt, $args, $resultlist) = @_;

    my $outtype = $opt->{outtype} || 'yaml';
    if ($outtype eq "yaml")
    {
            require YAML::Syck;
            print YAML::Syck::Dump($resultlist);
    }
    elsif ($outtype eq "json")
    {
            eval "use JSON -convert_blessed_universally";
            my $json = JSON->new->allow_nonref->pretty->allow_blessed->convert_blessed;
            print $json->encode($resultlist);
    }
    elsif ($outtype eq "ini") {
            require Config::INI::Writer;
            Config::INI::Writer->write_string($resultlist);
    }
    elsif ($outtype eq "dumper")
    {
            require Data::Dumper;
            print Data::Dumper::Dumper($resultlist);
    }
    else
    {
            die "Unrecognized output type: $outtype";
    }
}

sub run {
        my ($self, $opt, $args) = @_;

        my $path    = $args->[0];
        my $file    = $args->[1] || '-';

        my $data   = $self->read_in( $opt, $args, $file );
        my $result = $self->match(   $opt, $args, $data, $path );

        use Data::Dumper;
        $self->write_out( $opt, $args, $result );
}

# $ yourcmd blort --recheck

1;

=head1 NAME

App::DPath::Command::search - The default subcommand to search by dpath, can be omitted

=head1 FUNCTIONS

This is not an end user module but used as cmdline tool. The functions
here are only named to keep Pod::Coverage happy.

=head2 read_in

Reads in a file and converts it according to format.

=head2 match

Does the match against the given dpath.

=head2 write_out

Writes out the result set according to format.

=head2 opt_spec

=head2 run

=head2 validate_args

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

