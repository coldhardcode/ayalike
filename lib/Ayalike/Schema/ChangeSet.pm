package Ayalike::Schema::ChangeSet;

use strict;
use warnings;

use Text::Diff qw(diff);

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'InflateColumn::DateTime', 'Core');
__PACKAGE__->table('changesets');
__PACKAGE__->add_columns(
    id  => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_auto_increment => 1,
    },
    site_id => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_foreign_key  => 1
    },
    user_id => {
        data_type   => 'VARCHAR',
        is_nullable => 0,
        size        => '64',
    },
    comment => {
        data_type   => 'TEXT',
        is_nullable => 0,
        size        => undef
    },
    date_to_publish => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        size        => undef
    },
    date_created => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        size        => undef,
    }
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to('site' => 'Ayalike::Schema::Site', 'site_id');
__PACKAGE__->has_many('revisions' => 'Ayalike::Schema::Revision', 'changeset_id');
__PACKAGE__->has_many('labels' => 'Ayalike::Schema::Label', 'changeset_id');

=item revision_count

I hate wantarray.

=cut
sub revision_count {
    my $self = shift();

    return $self->revisions->count();
}

=item applied

Checks to see if all revisions have been applied.  Returns true or false.

=cut
sub applied {
    my $self = shift();

    my $revs = $self->revisions();
    while(my $rev = $revs->next()) {
        unless($rev->applied()) {
            return 0;
        }
    }

    return 1;
}


=item populate

Populates a changeset with a list of Revisions

=cut
sub populate {
    my $self = shift();
    my $workings = shift();

    my $count = 0;
    foreach my $we (@{ $workings }) {

        if($we->is_out_of_date()) {
            next;
        }

        my $entry = $we->entry();

        my $diff = diff(\($entry->contents()), \($we->contents()),
            { STYLE => 'Unified'}
        );

        my $now = new Ayalike::Date();

        # Create a revision to represent what just took place.
        $self->add_to_revisions({
            entry_id => $we->entry_id(),
            user_id => $self->user_id(),
            diff    => $diff,
            applied => 0,
            date_created => $now
        });

        $we->delete();
        $count++;
    }

    return $count;
}

1;