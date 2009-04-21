package App::DPath::Command::search;

use App::DPath -command;

use strict; 
use warnings;

sub opt_spec {
    return (
	[ "blortex|X",  "use the blortex algorithm" ],
	[ "recheck|r",  "recheck all results"       ],
	);
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    
    # no args allowed but options!
    $self->usage_error("No args allowed") if @$args;
}

sub run {
    my ($self, $opt, $args) = @_;

    my $result = $opt->{blortex} ? "blortex()" : "blort()";
    recheck($result) if $opt->{recheck};
    print $result, "\n";
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

