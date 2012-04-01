package App::DPath::Command::search;

use App::DPath -command;

use strict;
use warnings;

use Data::DPath 'dpath';

sub opt_spec {
        return (
                [ "intype|i=s",   "input format, [yaml(default), json, dumper, ini, tap, xml]"  ],
                [ "outtype|o=s",  "output format, [yaml(default), json, dumper, xml]" ],
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

        if (not defined $filecontent or $filecontent !~ /[^\s\t\r\n]/ms) {
                print STDERR "Please provide some input data.\n";
                exit 1;
        }

        if ($intype eq "yaml") {
                require YAML::Any;
                $data = YAML::Any::Load($filecontent);
        }
        elsif ($intype eq "json") {
                require JSON;
                $data = JSON::decode_json($filecontent);
        }
        elsif ($intype eq "xml")
        {
                require XML::Simple;
                my $xs = new XML::Simple;
                $data  = $xs->XMLin($filecontent, KeepRoot => 1);
        }
        elsif ($intype eq "ini") {
                # require Config::INI::Reader;
                # $data = Config::INI::Reader->read_string($filecontent);
                $data = $self->deserialize($filecontent);
        }
        elsif ($intype eq "cfggeneral") {
                require Config::General;
                my %data = Config::General->new(-String => $filecontent,
                                                -InterPolateVars => 1,
                                               )->getall;
                $data = \%data;
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
sub format_stringify {
    my ($self, $resultlist) = @_;

    my $output = "";
    foreach my $entry (@$resultlist) {
            $output .= $entry."\n";
    }
    return $output;
}

# stolen from App::Serializer::Ini
sub serialize {
    my ($self, $data) = @_;
    $self->_serialize($data, "");
}
sub _serialize {
    my ($self, $data, $section) = @_;
    my ($section_data, $idx, $key, $elem);
    if (ref($data) eq "ARRAY") {
        for ($idx = 0; $idx <= $#$data; $idx++) {
            $elem = $data->[$idx];
            if (!ref($elem)) {
                $section_data .= "[$section]\n" if (!$section_data && $section);
                $section_data .= "$idx = $elem\n";
            }
        }
        for ($idx = 0; $idx <= $#$data; $idx++) {
            $elem = $data->[$idx];
            if (ref($elem)) {
                $section_data .= $self->_serialize($elem, $section ? "$section.$idx" : $idx);
            }
        }
    }
    elsif (ref($data)) {
        foreach $key (sort keys %$data) {
            $elem = $data->{$key};
            if (!ref($elem)) {
                no warnings 'uninitialized';
                $section_data .= "[$section]\n" if (!$section_data && $section);
                $section_data .= "$key = $elem\n";
            }
        }
        foreach $key (sort keys %$data) {
            $elem = $data->{$key};
            if (ref($elem)) {
                $section_data .= $self->_serialize($elem, $section ? "$section.$key" : $key);
            }
        }
    }

    return $section_data;
}
sub get_branch {
    my ($self, $branch_name, $create, $ref) = @_;
    my ($sub_branch_name, $branch_piece, $attrib, $type, $branch, $cache_ok);
    $ref = $self if (!defined $ref);

    # check the cache quickly and return the branch if found
    $cache_ok = (ref($ref) ne "ARRAY" && $ref eq $self); # only cache from $self
    $branch = $ref->{_branch}{$branch_name} if ($cache_ok);
    return ($branch) if (defined $branch);

    # not found, so we need to parse the $branch_name and walk the $ref tree
    $branch = $ref;
    $sub_branch_name = "";

    # these: "{field1}" "[3]" "field2." are all valid branch pieces
    while ($branch_name =~ s/^([\{\[]?)([^\.\[\]\{\}]+)([\.\]\}]?)//) {

        $branch_piece = $2;
        $type = $3;
        $sub_branch_name .= ($3 eq ".") ? "$1$2" : "$1$2$3";

        if (ref($branch) eq "ARRAY") {
            if (! defined $branch->[$branch_piece]) {
                if ($create) {
                    $branch->[$branch_piece] = ($type eq "]") ? [] : {};
                    $branch = $branch->[$branch_piece];
                    $ref->{_branch}{$sub_branch_name} = $branch if ($cache_ok);
                }
                else {
                    return(undef);
                }
            }
            else {
                $branch = $branch->[$branch_piece];
                $sub_branch_name .= "$1$2$3";   # accumulate the $sub_branch_name
            }
        }
        else {
            if (! defined $branch->{$branch_piece}) {
                if ($create) {
                    $branch->{$branch_piece} = ($type eq "]") ? [] : {};
                    $branch = $branch->{$branch_piece};
                    $ref->{_branch}{$sub_branch_name} = $branch if ($cache_ok);
                }
                else {
                    return(undef);
                }
            }
            else {
                $branch = $branch->{$branch_piece};
            }
        }
        $sub_branch_name .= $type if ($type eq ".");
    }
    return $branch;
}
sub set {
    my ($self, $property_name, $property_value, $ref) = @_;
    #$ref = $self if (!defined $ref);

    my ($branch_name, $attrib, $type, $branch, $cache_ok);
    if ($property_name =~ /^(.*)([\.\{\[])([^\.\[\]\{\}]+)([\]\}]?)$/) {
        $branch_name = $1;
        $type = $2;
        $attrib = $3;
        $cache_ok = (ref($ref) ne "ARRAY" && $ref eq $self);
        $branch = $ref->{_branch}{$branch_name} if ($cache_ok);
        $branch = $self->get_branch($1,1,$ref) if (!defined $branch);
    }
    else {
        $branch = $ref;
        $attrib = $property_name;
    }

    if (ref($branch) eq "ARRAY") {
        $branch->[$attrib] = $property_value;
    }
    else {
        $branch->{$attrib} = $property_value;
    }
}
sub deserialize {
    my ($self, $inidata) = @_;
    my ($data, $r, $line, $attrib_base, $attrib, $value);

    $data = {};

    $attrib_base = "";
    foreach $line (split(/\n/, $inidata)) {
        next if ($line =~ /^;/);  # ignore comments
        next if ($line =~ /^#/);  # ignore comments
        if ($line =~ /^\[([^\[\]]+)\] *$/) {  # i.e. [Repository.default]
            $attrib_base = $1;
        }
        if ($line =~ /^ *([^ =]+) *= *(.*)$/) {
            $attrib = $attrib_base ? "$attrib_base.$1" : $1;
            $value = $2;
            $self->set($attrib, $value, $data);
        }
    }
    return $data;
}
# END stolen ::App::Serialize::Ini

sub write_out {
    my ($self, $opt, $args, $resultlist) = @_;

    my $outtype = $opt->{outtype} || 'yaml';
    if ($outtype eq "yaml")
    {
            require YAML::Any;
            print YAML::Any::Dump($resultlist);
    }
    elsif ($outtype eq "json")
    {
            eval "use JSON -convert_blessed_universally";
            my $json = JSON->new->allow_nonref->pretty->allow_blessed->convert_blessed;
            print $json->encode($resultlist);
    }
    elsif ($outtype eq "ini") {
            print $self->serialize($resultlist);
    }
    elsif ($outtype eq "dumper")
    {
            require Data::Dumper;
            print Data::Dumper::Dumper($resultlist);
    }
    elsif ($outtype eq "xml")
    {
            require XML::Simple;
            my $xs = new XML::Simple;
            print $xs->XMLout($resultlist, AttrIndent => 1, KeepRoot => 1);
    }
    elsif ($outtype eq "stringify") {
            print $self->format_stringify( $resultlist );
    }
    else
    {
            die "Unrecognized output type: $outtype";
    }
}

sub execute {
        my ($self, $opt, $args) = @_;

        my $path    = $args->[0];
        my $file    = $args->[1] || '-';

        my $data    = $self->read_in( $opt, $args, $file );
        my $result  = $self->match(   $opt, $args, $data, $path );
        $self->write_out( $opt, $args, $result );
}

1;

=head1 NAME

App::DPath::Command::search - Default subcommand to search by dpath

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

=head2 execute

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

