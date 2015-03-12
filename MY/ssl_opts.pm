package MY::ssl_opts;
use strict;
use warnings;
our $VERSION = '0.05';
use CACertOrg::CA;
use parent qw( CPAN::Mini::Inject::Remote::ssl_opts );
sub SSL_ca_file { $_[0]->SUPER::SSL_ca_file || CACertOrg::CA::SSL_ca_file }
1;
