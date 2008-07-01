package Ayalike::Schema::Revision;

use strict;
use warnings;

use Text::Patch qw(patch);

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'InflateColumn::DateTime', 'Core');
__PACKAGE__->table('revisions');
__PACKAGE__->add_columns(
    id  => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_auto_increment => 1,
    },
    changeset_id => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_foreign_key => 1
    },
    entry_id => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_foreign_key => 1
    },
    user_id => {
        data_type   => 'VARCHAR',
        is_nullable => 0,
        size        => '64',
    },
    applied => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => 0,
        default     => 0
    },
    diff => {
        data_type   => 'TEXT',
        is_nullable => 0,
        size        => undef,
    },
    date_created => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        size        => undef,
    }
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to('changeset' => 'Ayalike::Schema::ChangeSet', 'changeset_id');
__PACKAGE__->belongs_to('entry' => 'Ayalike::Schema::Entry', 'entry_id');

=item apply

Apply this Revision to it's Entry.  If the Revision is marked 'applied' it
will not re-apply.  Marks the revision as applied. Returns a 1 for success, 0
for failure.

=cut
sub apply {
    my $self = shift();
    
    if($self->applied()) {
        return 0;
    }
    
    my $entry = $self->entry();
    my $new = patch($entry->contents(), $self->diff(),
        { STYLE => 'Unified'}
    );
    
    $entry->update({
       contents             => $new,
       date_last_modified   => new Ayalike::Date()
    });
    $self->update({ applied => 1});
    
    return 1;
}

1;