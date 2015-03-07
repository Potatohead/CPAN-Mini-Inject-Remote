#!perl -T

use strict;
use warnings;
use Test::More;

eval "use CACertOrg::CA";
plan skip_all => "CACertOrg::CA" if $@;
plan tests => 6;

use CPAN::Mini::Inject::Remote;

my @ssl_opts = (qw/SSL_ca_file SSL_cert_file SSL_key_file verify_hostnames/);

SKIP: {
    local $ENV{MCPANI_REMOTE_CONFIG} = 'MY/ssl_opts2.yml';
    skip 'MY/ssl_opts', 4 unless -f $ENV{MCPANI_REMOTE_CONFIG};
    local @INC = (@INC, '.');

    {
        my $mcpan = CPAN::Mini::Inject::Remote->new();
        is ref $mcpan->{config}, 'MY::ssl_opts', 'odd yaml';
        ok !defined $mcpan->{config}{SSL_ca_file}, 'no ca_file';
        my $ua = $mcpan->_useragent;
        is $ua->{ssl_opts}{SSL_ca_file},
          CACertOrg::CA::SSL_ca_file(), 'default ca_file'
            or diag explain $ua->{ssl_opts};
    }

    {
        my $mcpan = CPAN::Mini::Inject::Remote->new();
        $mcpan->{config}{SSL_ca_file} = 'path/to/root.crt';
        my $ua = $mcpan->_useragent;
        isnt $ua->{ssl_opts}{SSL_ca_file}, CACertOrg::CA::SSL_ca_file(), 'ca_file'
          or diag explain $ua->{ssl_opts};
    }
}

SKIP: {
    local $ENV{MCPANI_REMOTE_CONFIG} = 'MY/ssl_opts2x.yml';
    skip 'MY/ssl_opts', 2 unless -f $ENV{MCPANI_REMOTE_CONFIG};
    local @INC = (@INC, '.');
    my $mcpan = CPAN::Mini::Inject::Remote->new();
    is ref $mcpan->{config}, 'MY::cant_locate', 'odd yaml cant_locate'
      or diag explain $mcpan->{config};
    $mcpan->{config}{SSL_ca_file} = 'path/to/root.crt';
    eval { $mcpan->_useragent };
    like $@, qr/can't locate/i, 'cant locate' or diag $@;
}

# done_testing;
