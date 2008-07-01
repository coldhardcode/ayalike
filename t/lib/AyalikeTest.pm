package #
    AyalikeTest;
    
use strict;
use warnings;

use Ayalike::Date;
use Ayalike::Schema;

sub init_schema {
    my $self = shift();
    
    my $schema = Ayalike::Schema->connect($self->_database());
    
    $schema->deploy();
    
    my $now = new Ayalike::Date();
    
    my $site = $schema->resultset('Site')->create({
       name => 'Test Site',
       path => 'var/test/site1',
       ttl  => 120,
       pipeline => 'Textile',
       date_created => $now
    });
    
    return $schema;
}

sub _database {
    my $self = shift();
    
    my $db = 't/var/ayalike.db';
    
    unlink($db) if -e $db;
    unlink($db.'-journal') if -e $db.'-journal';
    mkdir('t/var') unless -d 't/var';
    
    my $dsn = "dbi:SQLite:$db";
    
    my @connect = ($dsn, '', '', { AutoCommit => 1});
    
    return @connect;
}

1;