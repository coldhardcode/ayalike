package Ayalike::Controller::Admin::Site;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Ayalike::Controller::Admin::Site - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'admin/site/default.tt';
}

=head2 create

=cut

sub create : Local {
    my ( $self, $c ) = @_;

    if(lc($c->req->method()) eq 'post') {

        my $site = $c->model('DBIC::Site')->new({
            name    => $c->req->param('name'),
            path    => $c->req->param('path'),
            ttl     => $c->req->param('ttl'),
            pipeline => $c->req->param('pipe') || undef,
            date_created => new Ayalike::Date()
        });
        $c->stash->{'site'} = $site;

        $c->form(required => [qw(name ttl)]);
        if($c->check_form()) {
            $site->insert();
            $c->detach('/site/show', [ $site->id() ]);
        }
    }

    my $pipes = $c->config->{'pipelines'};
    $c->stash->{'pipelines'} = $pipes;

    $c->stash->{'template'} = 'admin/site/create.tt';
}

=item edit 

=cut
sub edit : Local {
    my ($self, $c, $id) = @_;
    
    my $site = $c->model('DBIC::Site')->find($id);
    $c->stash->{'site'} = $site;
    
    my $pipes = $c->config->{'pipelines'};
    $c->stash->{'pipelines'} = $pipes;
    
    $c->stash->{'template'} = 'admin/site/edit.tt';
}

=item save

=cut
sub save : Local {
    my ($self, $c, $id) = @_;
    
    my $site = $c->model('DBIC::Site')->find($id);
    
    $site->name($c->req->param('name'));
    $site->path($c->req->param('path'));
    $site->ttl($c->req->param('ttl'));
    $site->pipeline($c->req->param('pipe'));
    
    $c->form(required => [qw(name ttl)]);
    if($c->check_form()) {
        $site->update();
        $c->detach('/site/show', [ $site->id() ]);
    }
    
    $c->detach('edit', [ $site->id() ]);
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
