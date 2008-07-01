#!/usr/bin/perl
use strict;

use lib 'lib/';

use Config::Any;

use Ayalike::Date;
use Ayalike::Schema;

# Use the existing ConfigLoader stuff to get this info

my $config = Config::Any->load_files({
    files => [ 'ayalike.yml' ],
    use_ext => 1
});

my $schema = Ayalike::Schema->connection(@{
    $config->[0]->{'ayalike.yml'}->{'Model::DBIC'}->{'connect_info'}
});

my $now = new Ayalike::Date();

my $site = $schema->resultset('Site')->create({
    name    => 'Test Site',
    path    => '/dev/null',
    active  => 1,
    date_created => $now
});

$site->add_to_entries({
    name    => 'foo/bar/baz',
    active  => 1,
    contents => 'Hello World',
    date_last_modified => $now,
    date_created => $now
});