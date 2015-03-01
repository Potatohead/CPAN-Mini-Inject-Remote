package CPAN::Mini::Inject::Remote::ssl_opts;


=head1 NAME

CPAN::Mini::Inject::Remote::ssl_opts - A sample ssl_opts

=cut

use strict;
use warnings;

use parent 'CACertOrg::CA';

our $VERSION = '0.05';

our @OPT = qw/SSL_ca_file
              SSL_cert_file
              SSL_key_file
              verify_hostnames/;

=over

=item ssl_opts

=cut

sub ssl_opts {
    my $self = shift;
    map { ($_ => defined $self->{$_}?
             /file/? (glob $self->{$_})[0] : $self->{$_} :
             $self->$_ )
    } @OPT;
}


=item new

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    bless $_[0], $class;
}

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Christopher Mckay.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of CPAN::Mini::Inject::Remote::ssl_opts
