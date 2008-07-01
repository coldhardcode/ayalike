package Ayalike::Controller::Admin;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Ayalike::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    unless($c->check_user_roles(qw(Administrator))) {
        $c->stash->{'error'} = 'You are not an Administrator.';
        $c->detach('/default');
    }
}


=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
