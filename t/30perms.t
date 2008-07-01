use Test::More;
use Tree::Simple;
use Tree::Simple::Visitor::FindByPath;
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

my $tree = $site->get_tree_from_entries();
# my $visualize = Tree::Visualize->new($tree, 'ASCII', 'TopDown');
# print $visualize->draw();

# my $tree = $site->get_tree_from_entries();
my $visitor = new Tree::Simple::Visitor::FindByPath();
$visitor->setSearchPath(qw(foo/ bar/ baz));
$tree->accept($visitor);
my $fullresult = $visitor->getResult();
isa_ok($fullresult->getNodeValue(), 'Ayalike::Schema::Entry', 'got entry');
cmp_ok($fullresult->getNodeValue(), 'eq', 'baz', 'found baz by value');

$visitor->setSearchPath(qw(foo/));
$tree->accept($visitor);
my $fooresult = $visitor->getResult->getNodeValue();
isa_ok($fooresult, 'Ayalike::Directory', 'got directory');