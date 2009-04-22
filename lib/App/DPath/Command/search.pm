package App::DPath::Command::search;

use App::DPath -command;

use strict;
use warnings;

use Data::DPath 'dpath';

sub opt_spec {
        return (
                [ "intype|i=s",   "input format, [yaml(default), dumper]"  ],
                [ "outtype|o=s",  "output format, [yaml(default), dumper]" ],
               );
}

sub validate_args {
    my ($self, $opt, $args) = @_;
}

sub read_in {
        my ($self, $opt, $args, $file) = @_;

        my $intype  = $opt->{intype}  || 'yaml';
        print STDERR "intype: $intype\n";
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
        if ($intype eq "yaml") {
                require YAML::Syck;
                $data = YAML::Syck::Load($filecontent);
        }
        elsif ($intype eq "dumper") {
                eval '$data = my '.$filecontent;
        }
        else
        {
                die "Unrecognized input type: $intype";
        }
        return $data;
}

sub match {
        my ($self, $opt, $args, $data, $path) = @_;
        print "path: $path\n";
        require Data::Dumper;
        print "data: ".Data::Dumper::Dumper($data);
        my @resultlist = dpath($path)->match($data);
        print Data::Dumper::Dumper(\@resultlist);
        return \@resultlist;
}

sub write_out {
    my ($self, $opt, $args, $resultlist) = @_;

    my $outtype = $opt->{outtype} || 'yaml';
    print STDERR "outtype: $outtype\n";
    if ($outtype eq "yaml") {
            require YAML::Syck;
            print YAML::Syck::Dump($resultlist);
    } elsif ($outtype eq "dumper") {
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

#        print Data::Dumper::Dumper($opt);
#        print Data::Dumper::Dumper($args);

        my $path    = $args->[0];
        my $file    = $args->[1] || '-';

        write_out( $self,
                   $opt,
                   $args,
                   match($self,
                         $opt,
                         $args,
                         read_in( $self,
                                  $opt,
                                  $args,
                                  $file ),
                         $path ));
}

# $ yourcmd blort --recheck

1;

=head1 NAME

App::DPath::Command::search - The "search" subcommand.

=head1 FUNCTIONS

This module is meant to be used as cmdline tool. The functions are
described here mostly to keep Pod::Coverage happy.

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

