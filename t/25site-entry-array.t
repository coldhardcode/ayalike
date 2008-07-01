use strict;
use lib 't/lib';

use Ayalike::Date;

use Test::More;

use AyalikeTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@ ? (skip_all => 'Needs DBD::SQLite for testing') : ( tests => 4 );
}

my $schema = AyalikeTest->init_schema();
ok($schema, 'Got a schema');

my $site = $schema->resultset('Site')->find(
    { name => 'Test Site', { key => 'sites_name'} }
);

my $now = new Ayalike::Date();

my $entry1 = $site->add_to_entries({
   name     => 'test/entry',
   contents => '<html><body></body></html>',
   date_last_modified => $now,
   date_created => $now
});

my $entry2 = $site->add_to_entries({
   name     => 'foo/bar/baz',
   contents => '<html><body></body></html>',
   date_last_modified => $now,
   date_created => $now
});

my $entry3 = $site->add_to_entries({
   name     => 'woah/boy',
   contents => '<html><body></body></html>',
   date_last_modified => $now,
   date_created => $now
});

my $entry4 = $site->add_to_entries({
   name     => 'foo/wooptie',
   contents => '<html><body></body></html>',
   date_last_modified => $now,
   date_created => $now
});


my $ref = $site->get_entry_arrayref();
cmp_ok($ref->[0]->[0], 'eq', 'foo/', 'foo/');
cmp_ok($ref->[0]->[1]->[0], 'eq', 'bar/', 'bar/');
cmp_ok($ref->[0]->[1]->[1]->[0], 'eq', 'baz', 'baz');