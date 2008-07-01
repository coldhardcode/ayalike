#!/usr/bin/perl
use strict;

use lib 'lib/';

use Config::Any;

use Ayalike::Schema;

# Use the existing ConfigLoader stuff to get this info

my $config = Config::Any->load_files({
    files => [ 'ayalike.yml' ],
    use_ext => 1
});

my $schema = Ayalike::Schema->connection(@{
    $config->[0]->{'ayalike.yml'}->{'Model::DBIC'}->{'connect_info'}
});

$schema->deploy();
#print $schema->resultset('Entry')->count()."\n";
