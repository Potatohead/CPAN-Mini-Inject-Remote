#!perl -T

use strict;
use warnings;
use Test::More;

eval "use CACertOrg::CA";
plan skip_all => "CACertOrg::CA" if $@;
plan tests => 4;

use CPAN::Mini::Inject::Remote;

my @ssl_opts = (qw/SSL_ca_file SSL_cert_file SSL_key_file verify_hostnames/);

SKIP: {
    local $ENV{MCPANI_REMOTE_CONFIG} = 'MY/ssl_opts2.yml';
    skip 'MY/ssl_opts2.yml', 3 unless -f $ENV{MCPANI_REMOTE_CONFIG};
    local @INC = (@INC, '.');
    my ($mcpan, $ua);
    eval {
        $mcpan = CPAN::Mini::Inject::Remote->new();
        $ua = $mcpan->_useragent();
    };
    ok !$@, 'new' or diag $@;
    ok ref $mcpan->{config}, 'odd yaml';
    ok $ua && $ua->{ssl_opts}{SSL_ca_file} &&
      $ua->{ssl_opts}{SSL_ca_file} eq CACertOrg::CA::SSL_ca_file() &&
      $ua->{ssl_opts}{SSL_cert_file} &&
      $ua->{ssl_opts}{SSL_key_file}, 'ssl_opts'
      or diag explain $ua->{ssl_opts};
}

SKIP: {
    local $ENV{MCPANI_REMOTE_CONFIG} = 'MY/ssl_opts2x.yml';
    skip 'MY/ssl_opts2x.yml', 1 unless -f $ENV{MCPANI_REMOTE_CONFIG};
    local @INC = (@INC, '.');
    eval {
        if (my $mcpan = CPAN::Mini::Inject::Remote->new()) {
            $mcpan->_useragent;
        }
    };
    like $@, qr/can't locate/i, 'cant locate' or diag $@;
}

# done_testing;
