package Ayalike::Pipeline;
use Moose;
use MooseX::AttributeHelpers;

=head1 NAME

Ayalike::Pipeline - Formatting Pipeline

=head1 SYNOPSIS

  my $pipeline = new Ayalike::Pipeline();
  my $proc1 = new Ayalike::Processor::Markdown();
  $pipeline->add($proc1);
  my $formatted = $pipeline->process($text);

=head1 DESCRIPTION

The pipeline is a series of processors that consecutively transform the source
of an entry.  The pipeline is a stack and the text of the entry is passed to
each processor in turn, in the order it is added to the stack.

=head1 METHODS

=over 4

=item processors

=cut

=item count

Get the number of processors in the pipeline.

=item empty

Empty the pipeline

=item push

Add a processor to the end of the pipeline.

=item pop

Remove the last processor in the pipeline.

=cut
has 'processors' => (
    metaclass   => 'Collection::Array',
    is          => 'rw',
    isa         => 'ArrayRef[Ayalike::Processor]',
    default     => sub { [ ] },
    provides    => {
        count   => 'count',
        empty   => 'empty',
        push    => 'push',
        pop     => 'pop'
    }
);

=item create_from_processor_arrayref

Given an arrayref of processor names, creates a Pipeline that contains them.

=cut
sub create_from_processor_arrayref {
    my ($class, $procs) = @_;
    
    my $pipe = new Ayalike::Pipeline();
    
    unless(defined($procs)) {
        return $pipe;
    }
    
    foreach my $proc (@{ $procs }) {
        eval "require $proc";
        if($@) {
            die("Couldn't find processor '$proc': $@");
        }
        
        my $pobj = $proc->new();
        $pipe->push($pobj);
    }
    
    return $pipe;
}

=item execute

Calls each processor (in the order they are added) and passes the results of
each processor to the process method of the next.  The final text is returned.

=cut
sub execute {
    my ($self, $text) = @_;
    
    foreach my $proc (@{ $self->processors }) {
        $text = $proc->process($text);
    }
    
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