package App::DPath::Command::search;
# ABSTRACT: Default subcommand to search by dpath

use App::DPath -command;

use strict;
use warnings;

use Data::DPath 'dpath';
use Scalar::Util 'reftype';

sub opt_spec {
        return (
                [ "intype|i=s",    "input format, [yaml(default), json, dumper, ini, tap, xml]"  ],
                [ "outtype|o=s",   "output format, [yaml(default), json, dumper, xml]" ],
                [ "separator|s=s", "sub entry separator for output format 'flat' (default=;)" ],
                [ "fb",            "on output format 'flat' use [brackets] around outer arrays" ],
                [ "fi",            "on output format 'flat' prefix outer array lines with index" ],
               );
}

sub validate_args {
    my ($self, $opt, $args) = @_;

    if (not $args->[0]) {
            die "dpath: please specify a dpath.\n";
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
                        open (my $FH, "<", $file) or die "dpath: cannot open input file $file.\n";
                        $filecontent = <$FH>;
                        close $FH;
                }
        }

        if (not defined $filecontent or $filecontent !~ /[^\s\t\r\n]/ms) {
                die "dpath: no meaningful input to read.\n";
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
                require Config::INI::Serializer;
                my $ini = Config::INI::Serializer->new;
                $data = $ini->deserialize($filecontent);
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
                die "dpath: unrecognized input format: $intype.\n";
        }
        return $data;
}

sub match {
        my ($self, $opt, $args, $data, $path) = @_;

        if (not $data) {
                die "dpath: no input data to match.\n";
        }

        my @resultlist = dpath($path)->match($data);
        return \@resultlist;
}

sub _format_flat_inner_scalar {
    my ($self, $opt, $result) = @_;

    return "$result";
}

sub _format_flat_inner_array {
    my ($self, $opt, $result) = @_;

    return join($opt->{separator}, map {
                                        # only SCALARS allowed (where reftype returns undef)
                                        die "dpath: unsupported innermost nesting (".reftype($_).") for 'flat' output.\n" if defined reftype($_);
                                        "".$_
                                       } @$result);
}

sub _format_flat_inner_hash {
    my ($self, $opt, $result) = @_;

    return join($opt->{separator}, map { my $v = $result->{$_};
                                         # only SCALARS allowed (where reftype returns undef)
                                         die "dpath: unsupported innermost nesting (".reftype($v).") for 'flat' output.\n" if defined reftype($v);
                                         "$_=".$v
                                       } keys %$result);
}

sub _format_flat_outer {
    my ($self, $opt, $result) = @_;

    my $output = "";
    die "dpath: can not flatten data structure (undef) - try other output format.\n" unless defined $result;

    my $A = ""; my $B = ""; if ($opt->{fb}) { $A = "["; $B = "]" }
    my $fi = $opt->{fi};

    if (!defined reftype $result) { # SCALAR
            $output .= $result."\n"; # stringify
    }
    elsif (reftype $result eq 'ARRAY') {
            for (my $i=0; $i<@$result; $i++) {
                    my $entry  = $result->[$i];
                    my $prefix = $fi ? "$i:" : "";
                    if (!defined reftype $entry) { # SCALAR
                            $output .= $prefix.$A.$self->_format_flat_inner_scalar($opt, $entry)."$B\n";
                    }
                    elsif (reftype $entry eq 'ARRAY') {
                            $output .= $prefix.$A.$self->_format_flat_inner_array($opt, $entry)."$B\n";
                    }
                    elsif (reftype $entry eq 'HASH') {
                            $output .= $prefix.$A.$self->_format_flat_inner_hash($opt, $entry)."$B\n";
                    }
                    else {
                            die "dpath: can not flatten data structure (".reftype($entry).").\n";
                    }
            }
    }
    elsif (reftype $result eq 'HASH') {
            my @keys = keys %$result;
            foreach my $key (@keys) {
                    my $entry = $result->{$key};
                    if (!defined reftype $entry) { # SCALAR
                            $output .= "$key:".$self->_format_flat_inner_scalar($opt, $entry)."\n";
                    }
                    elsif (reftype $entry eq 'ARRAY') {
                            $output .= "$key:".$self->_format_flat_inner_array($opt, $entry)."\n";
                    }
                    elsif (reftype $entry eq 'HASH') {
                            $output .= "$key:".$self->_format_flat_inner_hash($opt, $entry)."\n";
                    }
                    else {
                            die "dpath: can not flatten data structure (".reftype($entry).").\n";
                    }
            }
    }
    else {
            die "dpath: can not flatten data structure (".reftype($result).") - try other output format.\n";
    }

    return $output;
}

sub _format_flat {
    my ($self, $opt, $resultlist) = @_;

    my $output = "";
    $opt->{separator} = ";" unless defined $opt->{separator};
    $output .= $self->_format_flat_outer($opt, $_) foreach @$resultlist;
    return $output;
}

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
            require Config::INI::Serializer;
            my $ini = Config::INI::Serializer->new;
            print $ini->serialize($resultlist);
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
    elsif ($outtype eq "flat") {
            print $self->_format_flat( $opt, $resultlist );
    }
    else
    {
            die "dpath: unrecognized output format: $outtype.";
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

__END__

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

=cut
