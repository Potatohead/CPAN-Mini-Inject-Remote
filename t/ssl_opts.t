#!perl -T

use strict;
use warnings;
use Test::More; # tests => 11;
use YAML::Any qw(Load);

BEGIN { use_ok( 'CPAN::Mini::Inject::Remote::ssl_opts' ) }
BEGIN { use_ok( 'CPAN::Mini::Inject::Remote' ) }

my @ssl_opts = (qw/SSL_ca_file SSL_cert_file SSL_key_file verify_hostnames/);

{
    my $c = Load(<<END);
remote_server: https://mcpani.your.org
SSL_cert_file: ~/.certs/your.crt
SSL_key_file: ~/.certs/your.key
SSL_ca_file: ~/perl5/lib/perl5/CACertOrg/CA/root.crt
END
    ok $c->{remote_server}, 'remote_server' or diag $c->{remote_server};
    my $o = CPAN::Mini::Inject::Remote::ssl_opts->new($c);
    can_ok($o, @ssl_opts);
    my %ssl_opts = $o->ssl_opts;
    ok exists $ssl_opts{$_}, $_ or diag explain \%ssl_opts for @ssl_opts ;
}

SKIP: {
    local $ENV{MCPANI_REMOTE_CONFIG} = 'MY/ssl_opts.yml';
    skip 'MY/ssl_opts', 4 unless -f $ENV{MCPANI_REMOTE_CONFIG};
    local @INC = (@INC, '.');
    my $mcpan = CPAN::Mini::Inject::Remote->new();
    my $ua = $mcpan->_useragent();
    my %ssl_opts = %{$ua->{ssl_opts}};
    ok exists $ssl_opts{$_}, $_ or diag explain \%ssl_opts for @ssl_opts ;
}

done_testing;
