package Ayalike::Controller::Site;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Ayalike::Date;

=head1 NAME

Ayalike::Controller::Site - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 show

=cut
sub show : Local {
    my ($self, $c, $id) = @_;
    
    my $site = $c->model('DBIC::Site')->find($id);
    
    $c->stash->{'site'} = $site;
    my @entries = $site->entries;
    $c->stash->{'entries'} = \@entries;
    
    $c->stash->{'template'} = 'site/show.tt';
}

=head2 review_commit

=cut
sub review_commit : Local {
    my ($self, $c) = @_;
    
    my $wes = $self->get_working_entries_from_params($c);
    $c->stash->{'working_entries'} = $wes;
    
    $c->stash->{'template'} = 'site/review_commit.tt';
}

=head2 commit

=cut
sub commit : Local {
    my ($self, $c) = @_;
    
    my $wes = $self->get_working_entries_from_params($c);
    
    unless(scalar(@{ $wes })) {
        $c->stash->{'warning'} = $c->localize('Nothing to publish.');
        $c->detach('/default');
    }
    $c->stash->{'working_entries'} = $wes;
    
    $c->form({ required => 'comment' });
    if(!$c->check_form()) {
        $c->stash->{'error'} = $c->localize('Please correct the errors in your form.');
        $c->detach('review_commit');
    }
    
    my $count = 0;
    
    my $schema = $c->model('DBIC')->schema();
    
    eval {
        $schema->txn_begin();

        my $cs = $schema->resultset('ChangeSet')->create({
            site_id => $wes->[0]->entry->site_id(),
            user_id => $c->user->id(),
            comment => $c->req->param('comment'),
            date_to_publish => new Ayalike::Date(),
            date_created => new Ayalike::Date()
        });
     
        $count = $cs->populate($wes);
        
        $schema->txn_commit();
    };
    if($@) {
        $c->stash->{'error'} = $@;
        $schema->txn_rollback();
        $c->detach('/default');
    }
    
    if($count) {
        $c->stash->{'success'} = $c->localize('Committed [_1] entries.', $count);
    }
    $c->detach('/default');
}

=head get_working_entries_from_params

Returns an arrayref of WorkingEntries based on parameters like we_\d+

=cut
sub get_working_entries_from_params {
    my ($self, $c) = @_;
    
    my @wes;
    foreach my $p (keys(%{ $c->req->params() })) {
        if($p =~ /we_(\d+)/) {
            my $we = $c->model('DBIC::WorkingEntry')->find($1);
            # FIXME Admins can commit anything
            if($we->user_id() != $c->user->id()) {
                next;
            }
            push(@wes, $we);
        }
    }
    
    return \@wes;
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
