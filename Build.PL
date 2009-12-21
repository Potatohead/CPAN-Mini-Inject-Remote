use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'CPAN::Mini::Inject::Remote',
    license             => 'restrictive',
    dist_author         => q{Christopher Mckay <potatohead@potatolan.com>},
    dist_version_from   => 'lib/CPAN/Mini/Inject/Remote.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'CPAN-Mini-Inject-Remote-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
