package Ayalike::Schema::User;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'InflateColumn::DateTime', 'Core');
__PACKAGE__->table('users');
__PACKAGE__->add_columns(
    id  => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        is_auto_increment => 1,
    },
    name => {
        data_type   => 'VARCHAR',
        is_nullable => 0,
        size        => 255
    },
    username => {
        data_type   => 'VARCHAR',
        is_nullable => 0,
        size        => 64,
    },
    password => {
        data_type   => 'VARCHAR',
        is_nullable => 0,
        size        => 64,
    },
    active => {
        data_type   => 'INTEGER',
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
    'users_username' => [ qw/username/ ],
);

__PACKAGE__->has_many('working_entries' => 'Ayalike::Schema::WorkingEntry', 'user_id');
__PACKAGE__->has_many('revisions' => 'Ayalike::Schema::Revision', 'user_id');
__PACKAGE__->has_many('user_roles' => 'Ayalike::Schema::UserRole', 'user_id');
__PACKAGE__->many_to_many('roles' => 'user_roles', 'role');

1;