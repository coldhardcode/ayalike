use strict;
use lib 't/lib';

use Test::More;

use AyalikeTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@ ? (skip_all => 'Needs DBD::SQLite for testing') : ( tests => 3 );
}

my $schema = AyalikeTest->init_schema();
ok($schema, 'Got a schema');

my $site = $schema->resultset('Site')->find(
    { name => 'Test Site' }, { key => 'sites_name' }
);
cmp_ok($site->name(), 'eq', 'Test Site', 'test site');
cmp_ok("$site", 'eq', 'Test Site', 'stringify');
