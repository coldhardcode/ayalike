use Test::More tests => 5;

BEGIN {
    use_ok('Ayalike::Directory');
}

my $dir = new Ayalike::Directory(name => 'foo', owner => 'Admin');
isa_ok($dir, 'Ayalike::Directory');
cmp_ok($dir->name(), 'eq', 'foo', 'name');
cmp_ok($dir->owner(), 'eq', 'Admin', 'owner');
cmp_ok("$dir", 'eq', 'foo/', 'stringify');