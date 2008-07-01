package Ayalike::Controller::Entry;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Ayalike::Pipeline;

=head1 NAME

Ayalike::Controller::Entry - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'entry/default.tt';
}

=head2 list

=cut
sub list : Local {
    my ($self, $c, $id) = @_;

    my $site = $c->model('DBIC::Site')->find($id);
    $c->stash->{'site'} = $site;
    my @entries = $site->entries->search({ active => 1 }, { order_by => 'name'});
    $c->stash->{'entries'} = \@entries;

    $c->stash->{'template'} = 'entry/list.tt';
}

=head2 create

=cut
sub create : Local {
    my ( $self, $c, $id ) = @_;

	# Check permissions?
	my $site = $c->model('DBIC::Site')->find($id);
	$c->stash->{'site'} = $site;
	unless($site) {
		$c->stash->{'error'} = $c->localize('Invalid site, [_1]', $id);
		$c->detach('/default');
	}

    if(lc($c->req->method()) eq 'post') {

		my $now = new Ayalike::Date();
        my $entry = $c->model('DBIC::Entry')->new({
            name    => $c->req->param('name'),
            site_id => $site->id(),
            contents => $c->req->param('contents'),
            date_created => $now,
			date_last_modified => $now
        });
        $c->stash->{'entry'} = $entry;

        $c->form(required => [qw(name contents)]);
        if($c->check_form()) {
            $entry->insert();
            $c->detach('show', [ $entry->id() ]);
        }
    }

    $c->stash->{'template'} = 'entry/create.tt';
}

=head2 show

=cut
sub show : Local {
    my ( $self, $c, $id ) = @_;

    my $entry = $c->model('DBIC::Entry')->find($id);
    $c->stash->{'entry'} = $entry;

    # I HATE WANTARRAY
    $c->stash->{'revision_count'} = $entry->revisions->count();

    $c->stash->{'template'} = 'entry/show.tt';
}

=head2 view

Returns the entry's contents directly in the body.  This controller is
intended for use with external systems who need to fetch templates.

NOTE: Sets the Cache-Control header to max-age: $site->ttl()

=cut
sub view : Local {
    my ( $self, $c) = @_;

    my $args = $c->request->args();

    my $site = $c->model('DBIC::Site')->find(shift(@{ $args }));
    unless($site) {
        $c->response->status(404);
    }

    my $name = join('/', @{ $args });
    my $entry = $c->model('DBIC::Entry')->find(
        { site_id => $site->id(), name => $name }, { key => 'entries_site_id_name'}
    );

    my $pipe = new Ayalike::Pipeline->create_from_processor_arrayref(
        $c->config->{'pipelines'}->{$site->pipeline()}
    );
    
    my $contents = $entry->contents();
    
    if(defined($pipe)) {
        $contents = $pipe->execute($contents);
    }

    if($entry) {
        $c->response->header('Cache-Control' => 'max-age=' . $site->ttl());
        $c->response->body($contents);
    } else {
        $c->response->status(404);
        # $c->stash->{'error'} = 'Unknown Entry';
        # $c->detach('/default');
    }
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
