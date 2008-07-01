package Ayalike::Schema::Entry;

use strict;
use warnings;

use base 'DBIx::Class';

use File::Spec;

use overload '""' => sub { $_[0]->file_name() }, fallback => 1;

__PACKAGE__->load_components('PK::Auto', 'InflateColumn::DateTime', 'Core');
__PACKAGE__->table('entries');
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
        is_foreign_key => 1,
    },
    name => {
        data_type   => 'VARCHAR',
        is_nullable => 0,
        size        => 255
    },
    active => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        default_value => 1
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
    'entries_site_id_name' => [ qw/site_id name/ ],
);

__PACKAGE__->belongs_to('site' => 'Ayalike::Schema::Site', 'site_id');
__PACKAGE__->has_many('working_entries', => 'Ayalike::Schema::WorkingEntry', 'entry_id');
__PACKAGE__->has_many('revisions' => 'Ayalike::Schema::Revision', 'entry_id');

=item file_name

Returns the last part of the entry's name -- the 'file name'.

=cut
sub file_name {
    my $self = shift();
    
    my ($vol, $dir, $file) = File::Spec->splitpath($self->name());
    return $file;
}

1;