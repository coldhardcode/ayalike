package #
    TestTransformer;
use Moose;

extends 'Ayalike::Processor';

sub process {
    my ($self, $text) = @_;
    
    $text =~ s/FOO/BAR/g;
    return $text;
}

1;