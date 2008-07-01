use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use Text::Textile";
    plan $@ ? (skip_all => 'Needs Text::Textile for testing') : ( tests => 3 );
    use_ok('Ayalike::Processor::Textile');
}

my $proc = new Ayalike::Processor::Textile();
isa_ok($proc, 'Ayalike::Processor::Textile');

my $text = $proc->process('Hello World!');
cmp_ok($text, 'eq', "<p>Hello World!</p>", 'properly transformed');

