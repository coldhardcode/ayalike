use strict;
use lib 't/lib';

use Config::Any;
use File::Path;
use Test::More;

use Ayalike::Date;
use Ayalike::Pipeline;
use AyalikeTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@ ? (skip_all => 'Needs DBD::SQLite for testing') : ( tests => 7 );
}

my $schema = AyalikeTest->init_schema();
ok($schema, 'Got a schema');

my $site = $schema->resultset('Site')->find(
    { name => 'Test Site', { key => 'sites_name'} }
);

if(-e ($site->path())) {
    rmtree($site->path());
}

my $now = new Ayalike::Date();

my $entry1 = $site->add_to_entries({
   name     => 'test/entry',
   contents => 'I like _textile_ a lot.',
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

my $config = Config::Any->load_files({
    files => [ 'ayalike.yml' ],
    use_ext => 1
});

my $config = Config::Any->load_files({
    files => [ 'ayalike.yml' ],
    use_ext => 1
});

my $pipe = Ayalike::Pipeline->create_from_processor_arrayref(
    $config->[0]->{'ayalike.yml'}->{'pipelines'}->{$site->pipeline()}
);

cmp_ok($pipe->count(), '==', 1, 'proc count is 1');

my $ref = $site->publish($pipe);
ok(-e $site->path()."/".$entry1->name(), $site->path()."/".$entry1->name());

open(FILE, $site->path()."/".$entry1->name());
my $line = <FILE>;
close(FILE);
cmp_ok($line, 'eq', '<p>I like <em>textile</em> a lot.</p>', 'textile pipeline');

ok(-e $site->path()."/".$entry2->name(), 'entry 2 file');
ok(-e $site->path()."/".$entry3->name(), 'entry 3 file');
ok(-e $site->path()."/".$entry4->name(), 'entry 3 file');