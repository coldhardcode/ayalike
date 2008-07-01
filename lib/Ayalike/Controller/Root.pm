package Ayalike::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Ayalike::Controller::Root - Root Controller for Ayalike

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 auto

=cut
sub auto : Private {
    my ($self, $c) = @_;

    my @sites = $c->model('DBIC::Site')->search({ active => 1})->all();
    $c->stash->{'sites'} = \@sites;
}

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    unless($c->user() or ($c->action() =~ /login$/)) {
        $c->action(undef);
        $c->detach('/auth/default');
    }

    my $wesrs = $c->model('DBIC::WorkingEntry')->search({
        user_id => $c->user->id()
    });
    my @wes = $wesrs->all();
    $c->stash->{'working_entries'} = \@wes;

    my $recent_revs = $c->model('DBIC::Revision')->search(undef, {
        order_by=> \'date_created DESC',
        page    => 1,
        rows    => 10
    });
    my @revisions = $recent_revs->all();
    $c->stash->{'revisions'} = \@revisions;

    my $recent_cs = $c->model('DBIC::ChangeSet')->search(undef, {
        order_by=> \'date_to_publish DESC',
        page    => 1,
        rows    => 10
    });
    my @changesets = $recent_cs->all();
    $c->stash->{'changesets'} = \@changesets;

    $c->stash->{'template'} = 'default.tt';
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
