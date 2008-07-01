package Ayalike::Processor::Textile;
use Moose;

use Text::Textile;

extends 'Ayalike::Processor';

=head1 NAME

Ayalike::Processor::Textile - Textile formatting

=head1 SYNOPSIS

  my $proc = new Ayalike::Processor::Textile();
  $pipeline->add($proc);
  my $formatted = $pipeline->process($text);

=head1 DESCRIPTION

Hands off formatting to L<Text::Textile>.

=head1 METHODS

=over 4

=cut

has +'name' => (
    default => 'Textile'
);

=item textile

Allows you to supply your own Text::Textile object, rather than using the
default one.

=cut
has 'textile' => (
    isa => 'Text::Textile',
    is  => 'rw',
    default => sub { new Text::Textile() },
);

=item process

Format the text using Text::Textile

=cut
sub process {
    my ($self, $text) = @_;
    
    return $self->textile->process($text);
}

=back

=head1 AUTHOR

Cory Watson <gphat@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;