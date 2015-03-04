#!/usr/bin/env perl

use common::sense;
use Archive::Tar;
use CPAN::Meta;
use CPAN::DistnameInfo;
use Dist::Metadata;
use File::Spec::Functions qw(catfile splitdir);

my ($total, $ok1, $ok2, $ok3);
my $verbose = 0;
my %v;

my $mirror = 'mcpan';

open my $list, '-|', 'zcat', "$mirror/modules/02packages.details.txt.gz"
    or die "can't zcat";
{ local $/ = "\n\n";
  my $header = <$list>; }
while (<$list>) {
    chop;
    my ($m, $v, $p) = split /\s+/;
    push @{$v{$p}{$m}}, $v;
}
close $list;

open my $find, '-|', 'find', "$mirror/authors/id"
    or die "can't find mcpan";
while (<$find>) {
    chop;
    next unless /\.tar\.gz$/;
    $total++;

    my ($m1, $v1); eval { ($m1, $v1) = get_name_version1($_) };
    my ($m2, $v2); eval { ($m2, $v2) = get_name_version2($_) };
    my ($m3, $v3); eval { ($m3, $v3) = get_name_version3($_) };

    my @f = splitdir($_);
    my $f = catfile(splice(@f, 3));
    $ok1++ if $m1 && $v1 && grep $_ eq $v1, @{ $v{$f}{$m2} || [] };
    $ok2++ if $m2 && $v2 && grep $_ eq $v2, @{ $v{$f}{$m2} || [] };
    $ok3++ if $m3 && $v3 && grep $_ eq $v3, @{ $v{$f}{$m3} || [] };

    if ($total % 100 == 0)
    {
	print join("\t", qw(total ok1 ok2 ok3)), "\n";
	print join("\t", $total, map sprintf("%.1f%%", $_ / $total * 100),
		   $ok1, $ok2, $ok3), "\n";
    }
}

print join("\t", qw(total ok1 ok2 ok3)), "\n";
print join("\t", $total, map sprintf("%.1f%%", $_ / $total * 100),
	   $ok1, $ok2, $ok3), "\n";

=pod

total   ok1     ok2     ok3
21400   66.1%   82.8%   85.0%

1: get_name_version() in f268bac/bin/mcpani_remote
2: Dist::Metadata
3: CPAN::DistnameInfo

=cut

sub get_name_version1 {
    my $file = shift;
    (my $tar = Archive::Tar->new) or die "can't new Archive::Tar";
    if ($tar->read($file, { filter => qr/META/ }))
    {
	my @list = $tar->list_files([qw(name)]);
	for (grep /META/, @list)
	{
	    next unless my $string = $tar->get_content($_);
	    print $string if $verbose > 1;
	    next unless my $meta = CPAN::Meta->load_string($string);
	    (my $scan_version = $meta->version) .= '(?:_\d+)?';
	    my ($modversion) = $file =~ /($scan_version)/;
	    (my $scan_name = $meta->name) =~ s{-}{[/-]}g;
	    my ($modname) = map { /\b($scan_name)(\.\w+)?$/? $1 : () } @list;
	    $modname =~ s/\//::/g;
	    return ($modname, $modversion) if $modname && $modversion;
	}
    }
    ();
}


sub get_name_version2 {
    my $file = shift;
    my $d = CPAN::DistnameInfo->new($file);
    my ($modname, $modversion) = ($d->dist, $d->version);
    return () unless $modname && $modversion;
    $modname =~ s/-/::/g;
    ($modname, $modversion);
}


sub get_name_version3 {
    my $file = shift;
    return () unless my $d = Dist::Metadata->new(file => $file);
    my $p = $d->package_versions;
    (my $module = $d->name) =~ s/-/::/g;
    my $modversion = $p->{$module} || $d->version;
    ($module, $modversion);
}
