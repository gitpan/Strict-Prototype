
package Strict::Prototype;
use Filter::Util::Call;
use strict;
use Carp;

$VERSION = "0.10";

my %_types = (
    char => '\w+',
    int  => '\d+',
    array => 'ARRAY',
    hash  => 'HASH',
);


sub import {
   my ($type) = shift ;
   my ($type_checking) = shift || 0;
   #print "Imported with type of '$type'\n";
   my %context = (
         type_checking => $type_checking,
         line          => 0,
         file          => (caller)[1],
      ) ;
   filter_add(bless \%context) ;
}

sub filter {
   my ($self) = @_;
   my ($proto_stuff,$status,$data);
   $status = filter_read();
   ++$self->{line};
   
   if ($status <= 0) {
       return $status ;
   }
   $data = $_;

   ## Code block of the parsing
   my ($proto_stuff);
   {
       ## check the source.
       if ($data =~ m/(^|\s)sub\s+(\w+)/) {
           if ($data =~ m/(^|\s)sub\s+(\w+)\s+(\(.+\))/) {
                my ($varstr,$subname,$proto);
                my ($arg,$var,@args,@mvars,$type,$type_checking_code);
                $subname = $2;
                $proto = $3;
                if ($proto =~ m/^\([\%\@\&\$]+\)$/) {
                    &debug("    Proto Style : Native");
                } else {
                    &debug("    Proto Style : Special");
                    if ($self->{type_checking}) {
                        &debug("        -- Type Checked");
                        $data =~ s/((^|\s)sub\s+\w+\s+)\(.+\)/$1/;
                        my @args = split(/,/,$proto);
                        my @mvars;
                        foreach $arg (@args) {
                            if ($arg =~ m/\s*(\w+)\s+([\%\@\&\$]\w+)/) {
                                ## has type checks
                                $type = $1;
                                $var = $2;
                                push @mvars, $var;
                                $type_checking_code = "    die \"$subname called with incrrect argument type.\" if ($var !~ m/^$_types{$type}\$/);";
                            } else {
                                $self->egres("Type checking format violation.");
                            }
                        }
                        $varstr = join(',',@mvars);
                        $proto_stuff  = "    my ($varstr) = \@_;\n$type_checking_code\n";
                    } else {
                        &debug("        -- NOT Type Checked");
                        if ($proto =~ m/(\(|\s+)[A-Za-z]/) {
                            #appears someone has put types in a non-typed file
                            $self->egres("Prototype String contains non-variable enrty");
                        }
                        $proto_stuff = "    my $proto = \@_;\n";
                        $data =~ s/((^|\s)sub\s+\w+\s+)\(.+\)/$1/;
                    }
                }
           } else {
               &debug("Sub Def without proto.");
           }
       }

   }
   $_ = $data;
   #print "$data";
   if ($proto_stuff) {
       #print "$proto_stuff";
       $_ .= "$proto_stuff"; 
   }
   return $status;
}


sub egres {
    my ($self,$message) = @_;
    die "$message at $self->{file}, line $self->{line}\n"
}

sub debug {
    my ($message) = shift;
    warn "[DEBUG] : $message\n" if ($__PACKAGE__::debug);
}

1;
__END__

=head1 NAME

Strict ::Prototype - Improved Prototyping syntax.

=head1 SYNOPSIS

    use Strict::Prototype;
    
    sub subname ($msg) {
        print "$msg\n";
    }
    
    ...or...
    
    use Strict::Prototype qw(type_checking);
    
    sub subname (char $msg) {
        print "$msg\n";
    }
    

=head1 DESCRIPTION

C<Strict::Prototype> is used to allow prototypeing beyond the simple format provided by Perl.

=head1 OVERVIEW

The two uses of this module are mutually exclisive. In the simplist form, 
this module allows for inter-prototype variable definition similar to C. 
This can be used as a short cut for the common C<($a,$b,$c) = @_> idiom. 
Because the module is based on the source filtering model, it takes a small 
amount of time when the script starts up to modify the code prior to the 
intral compilation. 


The second use of this module is to add regular expression based type checking.
The only types currently allowed are C<char>,C<int>,C<array> and C<hash>. 
In the event of a type mis-match, die is called. Because all of the C<Strict::Prototype> 
work takes place prior to script execution, it should not cause any additional memory 
usage during processing.

=head1 REPORTING BUGS

When reporting bugs/problems please include as much information as possible.
It may be difficult for me to reproduce the problem as almost every setup
is different.

A small script which yields the problem will probably be of help. It would
also be useful if this script was run with C<$Strict::Prototype = 1> included in the program.  

=head1 PREREQUISITES

This script requires the C<Filter> module

=head1 AUTHOR

Matt Sanford <mzsanford@cpan.org>

=head1 SEE ALSO

L<Filter>

=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


