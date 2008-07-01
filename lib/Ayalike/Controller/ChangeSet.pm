package Ayalike::Controller::ChangeSet;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Ayalike::Controller::ChangeSet - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 show

=cut

sub show : Local {
    my ( $self, $c, $id ) = @_;

    my $cs = $c->model('DBIC::ChangeSet')->find($id);
    $c->stash->{'changeset'} = $cs;

    $c->stash->{'template'} = 'changeset/show.tt';
}

=head2 confirm

=cut
sub confirm : Local {
    my ($self, $c, $id) = @_;

    my $cs = $c->model('DBIC::ChangeSet')->find($id);
    $c->stash->{'changeset'} = $cs;

    $c->stash->{'template'} = 'changeset/confirm.tt';
}

=head2 apply

=cut
sub apply : Local {
    my ($self, $c, $id) = @_;

    my $cs = $c->model('DBIC::ChangeSet')->find($id);

    if($cs->applied()) {
        $c->stash->{'error'} = $c->loc('ChangeSet already applied.');
        $c->detach('/changeset/show', [ $cs->id() ]);
    }


    my $site = $cs->site();

    my $schema = $c->model('DBIC')->schema();

    my $applyref = sub {
        return $site->apply_changeset($cs);
    };

    my $changes;
    eval {
        $schema->txn_do($applyref);
    };

    if($@) {
        $c->stash->{'error'} = $c->loc("ChangeSet apply failed: [_1] $@", $@);
        $c->detach('/changeset/show', [ $cs->id() ]);
    }

    $c->stash->{'success'} = $c->loc('ChangeSet applied, [_1] revisions applied.', $changes);
    $c->detach('/changeset/show', [ $cs->id() ]);
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
