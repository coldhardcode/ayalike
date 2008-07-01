use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use Text::Markdown";
    plan $@ ? (skip_all => 'Needs Text::Markdown for testing') : ( tests => 3 );
    use_ok('Ayalike::Processor::Markdown');
}

my $proc = new Ayalike::Processor::Markdown();
isa_ok($proc, 'Ayalike::Processor::Markdown');

my $text = $proc->process('AT&T');
cmp_ok($text, 'eq', "<p>AT&amp;T</p>\n", 'properly transformed');

