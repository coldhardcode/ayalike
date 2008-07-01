package Ayalike::Schema::Label;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'InflateColumn::DateTime', 'Core');
__PACKAGE__->table('labels');
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
        is_foreign_key => 1
    },
    changeset_id => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_foreign_key => 1
    },
    name => {
        data_type   => 'VARCHAR',
        is_nullable => 0,
        size        => 255
    },
    date_created => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        size        => undef,
    }
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to('changeset' => 'Ayalike::Schema::ChangeSet', 'changeset_id');
__PACKAGE__->belongs_to('site' => 'Ayalike::Schema::Site', 'site_id');

1;