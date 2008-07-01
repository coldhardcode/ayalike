package Ayalike::Processor::Markdown;
use Moose;

use Text::Markdown;

extends 'Ayalike::Processor';

=head1 NAME

Ayalike::Processor::Markdown - Markdown formatting

=head1 SYNOPSIS

  my $proc = new Ayalike::Processor::Markdown();
  $pipeline->add($proc);
  my $formatted = $pipeline->process($text);

=head1 DESCRIPTION

Hands off formatting to L<Text::Markdown>.

=head1 METHODS

=over 4

=cut

has +'name' => (
    default => 'Markdown'
);

=item markdown

Allows you to supply your own Text::Markdown object, rather than using the
default one.

=cut
has 'markdown' => (
    isa => 'Text::Markdown',
    is  => 'rw',
    default => sub { new Text::Markdown() },
);

=item process

Format the text using Text::Markdown

=cut
sub process {
    my ($self, $text) = @_;
    
    return $self->markdown->markdown($text);
}

=back

=head1 AUTHOR

Cory Watson <gphat@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;