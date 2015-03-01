#!perl -T

use strict;
use warnings;
use Test::More tests => 5;
use YAML::Any qw(Load);

BEGIN {
    use_ok( 'CPAN::Mini::Inject::Remote::ssl_opts' );
}

{
    my $c = Load(<<END);
--- !!perl/hash:CPAN::Mini::Inject::Remote::ssl_opts
remote_server: https://mcpani.your.org
SSL_cert_file: ~/.certs/your.crt
SSL_key_file: ~/.certs/your.key
END
    ok ref $c, 'CPAN::Mini::Inject::Remote::ssl_opts' or diag explain $c;
    my $o = CPAN::Mini::Inject::Remote::ssl_opts->new($c);
    my %ssl_opts = $o->ssl_opts; my $e;
    ok $ssl_opts{SSL_ca_file}, 'SSL_ca_file' or $e++;
    ok !exists $ssl_opts{verify_hostnames}, 'verify_hostnames' or $e++;
    ok !exists $ssl_opts{remote_server}, 'remote_server' or $e++;
    diag explain(\%ssl_opts) if $e;
}
