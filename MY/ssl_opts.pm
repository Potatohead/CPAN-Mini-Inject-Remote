package MY::ssl_opts;
use strict;
use warnings;
our $VERSION = '0.05';
use parent qw( CACertOrg::CA );
use parent qw( CPAN::Mini::Inject::Remote::ssl_opts );
1;
