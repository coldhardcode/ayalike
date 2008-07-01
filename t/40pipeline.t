use strict;
use warnings;
use Test::More tests => 7;

use TestTransformer;

BEGIN {
    use_ok('Ayalike::Pipeline');
    use_ok('Ayalike::Processor');
};

my $pipe = new Ayalike::Pipeline();
isa_ok($pipe, 'Ayalike::Pipeline');

cmp_ok($pipe->count(), '==', 0, 'no processors');

my $proc = new TestTransformer();
isa_ok($proc, 'Ayalike::Processor');

$pipe->push($proc);
cmp_ok($pipe->count(), '==', 1, '1 processor in pipe');

my $text = $pipe->execute('FOO BAR BAZ');
cmp_ok($text, 'eq', 'BAR BAR BAZ', 'properly transformed');

