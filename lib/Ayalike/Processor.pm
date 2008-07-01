package Ayalike::Processor;
use Moose;

=head1 NAME

Ayalike::Processor - Text formatters

=head1 SYNOPSIS

  my $proc = new Ayalike::Processor::Markdown();
  $pipeline->add($proc);
  print "Added ".$proc->name()." to pipeline.\n";
  my $formatted = $pipeline->process($text);

=head1 DESCRIPTION

Processors are simple text converters.  Text goes in, formatted text comes
out.  You can chain them together with L<Ayalike::Pipeline>.

=head1 CREATING YOUR OWN

Rolling your own processor is simple:

  package Your::Processor::Foo;
  use Moose;
  
  extends 'Ayalike::Processor';
  
  sub process {
      my $self = shift();
      my $text = shift();
      
      # process the text
      $text =~ s/foo/bar/g;
      
      return $text
  }
  
  1;

=head1 METHODS

=over 4

=item name

=cut
has 'name' => (
    isa => 'Str',
    is  => 'ro',
    default => 'Base'
);


sub name {
    my ($self) = @_;
    
    return 'Base';
}

=item process

Process the supplied text and return it formatted.

=cut
sub process {
    my ($self, $text) = @_;
    
    return $text;
}

=back

=head1 AUTHOR

Cory Watson <gphat@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;