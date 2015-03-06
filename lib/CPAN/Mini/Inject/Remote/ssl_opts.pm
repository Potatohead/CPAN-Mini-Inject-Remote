package CPAN::Mini::Inject::Remote::ssl_opts;

use strict;
use warnings;

our $VERSION = '0.05';

=head1 NAME

CPAN::Mini::Inject::Remote::ssl_opts - A sample ssl_opts

=cut

my @OPTS = qw/
               SSL_ca_file
               SSL_cert_file
               SSL_key_file
               verify_hostnames
             /;

=over

=item SSL_ca_file, SSL_cert_file, SSL_key_file, verify_hostnames

see $ua->ssl_opts() in L<LWP::UserAgent>

=cut

{
    no strict 'refs';
    for my $name (@OPTS) {
        *$name = $name =~ /file/ ?
          sub { $_[0]->{$name} && (glob $_[0]->{$name})[0] } :
          sub { $_[0]->{$name} };
    }
}

=item ssl_opts

set of SSL options aboves

=cut

sub ssl_opts {
    my $self = shift;
    map { ($_ => $self->$_) } @OPTS;
}

=item new

constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    bless $_[0], $class;
}

1;

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Christopher Mckay.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of CPAN::Mini::Inject::Remote::ssl_opts
