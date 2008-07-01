package Ayalike::Schema::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'Core');
__PACKAGE__->table('user_roles');
__PACKAGE__->add_columns(
    role_id  => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
    },
    user_id  => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
    },
);
__PACKAGE__->set_primary_key(qw(role_id user_id));

__PACKAGE__->belongs_to('user' => 'Ayalike::Schema::User', 'user_id');
__PACKAGE__->belongs_to('role' => 'Ayalike::Schema::Role', 'role_id');

1;