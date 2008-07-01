package Ayalike::Controller::Auth;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Ayalike::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'auth/default.tmpl';
}

=head2 login

=cut

sub login : Local {
    my ($self, $c) = @_;

    if($c->authenticate({ username => $c->req->param('username'),
                          password => $c->req->param('password') })) {
        $c->detach('/default');
    } else {
        $c->stash->{'error'} = $c->localize('The supplied credentials are incorrect.');
    }

    $c->detach('default');
}

sub logout : Local {
    my ($self, $c) = @_;

    $c->logout();

    $c->detach('default');
}


=head1 AUTHOR

Cory Watson <gphat@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
