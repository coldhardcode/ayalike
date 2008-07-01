package Ayalike::Schema::Role;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'Core');
__PACKAGE__->table('roles');
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
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(
    'roles_name' => [ qw/name/ ],
);

__PACKAGE__->has_many('user_roles' => 'Ayalike::Schema::UserRole', 'user_id');
__PACKAGE__->many_to_many('users' => 'user_roles', 'user');

1;