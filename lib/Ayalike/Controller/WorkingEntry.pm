package Ayalike::Controller::WorkingEntry;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Ayalike::Date;

=head1 NAME

Ayalike::Controller::WorkingCopy - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 edit

=cut

sub edit : Local {
    my ( $self, $c, $id ) = @_;

    my $wc = $c->model('DBIC::WorkingEntry')->find(
        { user_id => $c->user->id(), entry_id => $id },
        { key => 'working_entry_entry_id_user_id'}
    );
    if($wc) {
        if($wc->is_out_of_date()) {
            $c->stash->{'warning'} = $c->localize('Your working entry is out of date and cannot be committed.');
        }
    } else {
        my $entry = $c->model('DBIC::Entry')->find($id);
        my $now = new Ayalike::Date();
        $wc = $c->model('DBIC::WorkingEntry')->new({
            entry_id    => $entry->id(),
            user_id     => $c->user->id(),
            contents    => $entry->contents()
        });
    }
    $c->stash->{'workingentry'} = $wc;

    $c->stash->{'template'} = 'workingentry/edit.tt';
}

=head2 show

=cut

sub show : Local {
    my ( $self, $c, $id ) = @_;

    my $we = $c->model('DBIC::WorkingEntry')->find($id);
    $c->stash->{'workingentry'} = $we;

    $c->stash->{'template'} = 'workingentry/show.tt';
}

=head2 save

=cut
sub save : Local {
    my ( $self, $c, $id ) = @_;

    my $entry = $c->model('DBIC::Entry')->find($id);
    my $now = new Ayalike::Date();

    my $wc;
    if($c->req->param('working_entry_id')) {
        $wc = $c->model('DBIC::WorkingEntry')->find(
            $c->req->param('working_entry_id')
        );

    } else {
        $wc = $c->model('DBIC::WorkingEntry')->new({
            entry_id    => $entry->id(),
            user_id     => $c->user->id(),
            date_created=> $now
        });
    }

    $wc->contents($c->req->param('contents'));
    if((!$wc->id()) && ($wc->contents() eq $entry->contents())) {
        $c->stash->{'warning'} = $c->localize('Nothing saved, as you made no changes.');
    } else {

        $wc->date_last_modified($now);
        $wc->update_or_insert();

        $c->stash->{'success'} = $c->localize('Saved working copy of entry [_1] ([_2])', $entry->id(), $wc->id());
    }

    $c->detach('/entry/show', [ $entry->id() ]);
}


=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
