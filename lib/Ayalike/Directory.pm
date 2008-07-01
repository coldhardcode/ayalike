package Ayalike::Directory;
use Moose;

use overload '""' => sub { $_[0]->name.'/' };

has 'name' => (
    'is'        => 'rw',
    'isa'       => 'Str',
    'required'  => 1
);

has 'owner' => (
    'is'        => 'rw',
    'isa'       => 'Str',
    'required'  => 1
);

1;