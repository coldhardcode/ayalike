use strict;
use lib 't/lib';

use Ayalike::Date;

use Test::More;

use AyalikeTest;

BEGIN {
    eval "use DBD::SQLite";
    plan $@ ? (skip_all => 'Needs DBD::SQLite for testing') : ( tests => 9 );
}

my $user_id = 'gphat';

my $schema = AyalikeTest->init_schema();
ok($schema, 'Got a schema');

my $site = $schema->resultset('Site')->find(
    { name => 'Test Site', { key => 'sites_name'} }
);

my $now = new Ayalike::Date();

my $entry = $site->add_to_entries({
   name     => '/test/entry',
   contents => '<html>
<body>
</body>
</html>',
   date_last_modified => $now,
   date_created => $now
});

ok($entry, 'got entry');

my $later = new Ayalike::Date();

my $new_contents = '<html>
<body>
hello world
</body>
</html>';

my $we = $entry->add_to_working_entries({
   user_id  => $user_id,
   contents => $new_contents,
   date_last_modified => $later,
   date_created => $later
});

isa_ok($we, 'Ayalike::Schema::WorkingEntry', 'working entry');

my $cs = $site->add_to_changesets({
    user_id         => $user_id,
    comment         => 'yay',
    date_to_publish => $later,
    date_created    => new Ayalike::Date()
});

$cs->populate([ $we ]);
cmp_ok($cs->revisions->count(), '==', 1, 'Revision count');
my $rev = $cs->revisions->first();
my $diff = $rev->diff();

like($diff, qr/\+hello world/, 'diff');
cmp_ok($cs->comment(), 'eq', 'yay', 'comment');
cmp_ok($entry->revisions->count(), '==', 1, '1 revision');

my $retval = $site->apply_changeset($cs);
cmp_ok($retval, '==', 1, '1 revision applied');
$entry->discard_changes();
cmp_ok($entry->contents(), 'eq', $new_contents, 'patch successful');
