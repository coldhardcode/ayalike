package Ayalike::Schema::WorkingEntry;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'InflateColumn::DateTime', 'Core');
__PACKAGE__->table('working_entries');
__PACKAGE__->add_columns(
    id  => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_auto_increment => 1,
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
    contents => {
        data_type   => 'TEXT',
        is_nullable => 0,
        size        => undef,
    },
    date_last_modified => {
        data_type   => 'DATETIME',
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
__PACKAGE__->add_unique_constraint(
    working_entry_entry_id_user_id => [ qw(entry_id user_id) ]
);

__PACKAGE__->belongs_to('entry' => 'Ayalike::Schema::Entry', 'entry_id');

=head2 is_out_of_date

Determines if this working entry is 'out of date', meaning that the entry
it came from has been updated since.

=cut
sub is_out_of_date {
    my $self = shift();
    
    if($self->date_created < $self->entry->date_last_modified()) {
        return 1;
    }
    
    return 0;
}

1;