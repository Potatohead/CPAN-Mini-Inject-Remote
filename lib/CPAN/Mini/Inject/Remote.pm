package CPAN::Mini::Inject::Remote;

use strict;
use warnings;
use Params::Validate qw/validate
                        SCALAR/;
use File::Spec;
use Config::Any;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common;
use Carp;

=head1 NAME

CPAN::Mini::Inject::Remote - Inject into your CPAN mirror from over here

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

describe the module, working code example

=cut

=head1 DESCRIPTION

=cut

=head1 FUNCTIONS

=cut

=head2 new

Class constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};
    bless ($self, $class);
    $self->_initialize(@_);
    return $self;
} # end of method new

######
#
# _initialize
# 
# Class properties initator
#
###

sub _initialize {
    my $self = shift;
    my %args = validate(@_,
        {
            config_file => {
                type => SCALAR,
                optional => 1,
            },
            remote_server => {
                type => SCALAR,
                optional => 1,
            },
        }
    );

    if (not $args{remote_server})
    {
        if (not $args{config_file})
        {
            $args{config_file} = $self->_find_config();
        }
        elsif (not -r $args{config_file})
        {
            croak "Supplied config file is not readable"; 
        }

        my $config = Config::Any->load_files(
            {files => [$args{config_file}]},
            flatten_to_hash => 1
        );

        $self->{remote_server} = $config->{$args{config_file}}->{remote_server};
    }
    else
    {
        $self->{remote_server} = $args{remote_server};
    }

} # end of method _initialize


######
#
# _find_config
#
# Attempts to find the config from a number of locations
# 
# locations are:-
#   argument passed in
#   specified in $ENV{MCPANI_REMOTE_CONFIG},
#   $ENV{HOME}/.mcpani_remote
#   /usr/local/etc/mcpani_remote
#   /etc/mcpani_remote
#
###

sub _find_config {
    my $self = shift;    
    my %args = validate(@_,
        {

        }
    );

    my @config_locations = (
        $ENV{MCPANI_REMOTE_CONFIG},
        (
            defined $ENV{HOME}
            ? File::Spec->catfile( $ENV{HOME}, qw/.mcpani_remote/)
            : ()
        ),
        File::Spec->catfile(
            File::Spec->rootdir(), 
            qw/usr local etc mcpani_remote/ 
        ),
        File::Spec->catfile(
            File::Spec->rootdir(), 
            qw/etc mcpani_remote/ 
        ),
    );

    for my $file ( @config_locations) {
        next unless defined $file;
        next unless -r $file;

        return $file;
    }

    croak "No config file was found that existed";
} # end of method _load_config


######
#
# _useragent
#
# loads up the user agent if one exists 
#
###

sub _useragent {
    my $self = shift;    
    my %args = validate(@_,
        {

        }
    );

    if (not $self->{useragent})
    {
        $self->{useragent} = LWP::UserAgent->new;
    }

    return $self->{useragent};
} # end of method _useragent


=head2 add

Calls the add function on the remote server

=cut

sub add {
    my $self = shift;    
    my %args = validate(@_,
        {
            module_name => {
                type => SCALAR,
            },
            author_id => {
                type => SCALAR,
            },
            version => {
                type => SCALAR,
            },
            file_name => {
                type => SCALAR,
            },
        }
    );

    if (not -r $args{file_name})
    {
        croak "Module file is not readable";
    }


    my $ua = $self->_useragent();

    my $response = $ua->request(PUT $self->{remote_server}.'/add',
        Content_Type => 'form-data',
        Content => [
            module => $args{module_name},
            authorid => $args{author_id},
            version => $args{version},
            file => [$args{file_name}],
        ]
    );

    if (not $response->is_success())
    {
        croak "Add failed. $response";
    }

    return;
} # end of method add


=head2 update

Calls the update function on the remote server

=cut

sub update {
    my $self = shift;    
    my %args = validate(@_,
        {

        }
    );

    my $ua = $self->_useragent();

    my $response = $ua->request(POST $self->{remote_server}.'/update');

    if (not $response->is_success())
    {
        croak "Update failed. $response";
    }

    return;
} # end of method update


=head2 inject

Calls the inject function on the remote server

=cut

sub inject {
    my $self = shift;    
    my %args = validate(@_,
        {

        }
    );
    
    my $ua = $self->_useragent();

    my $response = $ua->request(POST $self->{remote_server}.'/inject');

    if (not $response->is_success())
    {
        croak "Inject failed. $response";
    }

    return;
} # end of method inject


=head1 AUTHOR

Christopher Mckay, C<< <potatohead at potatolan.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cpan-mini-inject-remote at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CPAN-Mini-Inject-Remote>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CPAN::Mini::Inject::Remote


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CPAN-Mini-Inject-Remote>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CPAN-Mini-Inject-Remote>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CPAN-Mini-Inject-Remote>

=item * Search CPAN

L<http://search.cpan.org/dist/CPAN-Mini-Inject-Remote/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Christopher Mckay.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of CPAN::Mini::Inject::Remote
