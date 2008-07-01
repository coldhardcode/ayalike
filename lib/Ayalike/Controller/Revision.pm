package Ayalike::Controller::Revision;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Ayalike::Controller::Revision - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 show

=cut
sub show : Local {
    my ( $self, $c, $id ) = @_;

    my $rev = $c->model('DBIC::Revision')->find($id);
    $c->stash->{'revision'} = $rev;

    $c->stash->{'template'} = 'revision/show.tmpl';
}

=head2 list

=cut
sub list : Local {
    my ( $self, $c, $id ) = @_;

    my $rs;
    if($id) {
        my $entry = $c->model('DBIC::Entry')->find($id);
        $rs = $entry->revisions();
        $c->stash->{'entry'} = $entry;
    } else {
        $rs = $c->model('DBIC::Revision')->search();
    }

    $rs = $rs->search(undef, {
        page => $c->req->param('page') || 1,
        rows => $c->req->param('rows')
    });

    my @revisions = $rs->all();
    $c->stash->{'revisions'} = \@revisions;
    $c->stash->{'revision/list.tmpl'};
}


=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
