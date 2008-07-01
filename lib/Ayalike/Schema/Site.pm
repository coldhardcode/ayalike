package Ayalike::Schema::Site;
use strict;
use warnings;

use Ayalike::Directory;

use File::Path;
use File::Spec;
use Tree::Simple;
use Tree::Simple::Visitor::ToNestedArray;
use Tree::Simple::Visitor::CreateDirectoryTree;

use overload '""' => sub { $_[0]->name() }, fallback => 1;

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'InflateColumn::DateTime', 'Core');
__PACKAGE__->table('sites');
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
    ttl => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef
    },
    path => {
        data_type => 'VARCHAR',
        is_nullable => 1,
        size        => 150
    },
    pipeline => {
        data_type   => 'VARCHAR',
        is_nullable => 1,
        size        => 64
    },
    active => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        size        => undef,
        default_value => 1
    },
    date_created => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        size        => undef,
    }
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(
    'sites_name' => [ qw/name/ ],
);

__PACKAGE__->has_many('entries' => 'Ayalike::Schema::Entry', 'site_id');
__PACKAGE__->has_many('changesets' => 'Ayalike::Schema::ChangeSet', 'site_id');
__PACKAGE__->has_many('labels' => 'Ayalike::Schema::Label', 'site_id');

=head2 get_entry_arrayref

Returns an arrayref, wherein the 'directory structure' of the entries is
represented as an arrayref.

=cut
sub get_entry_arrayref {
    my $self = shift();

    my $tree = $self->get_tree_from_entries();

    my $visitor = new Tree::Simple::Visitor::ToNestedArray();
    $visitor->includeTrunk(0);
    $tree->accept($visitor);
    my $array = $visitor->getResults();

    return $array;
}

sub get_tree_from_entries {
    my $self = shift();

    my $entries = $self->entries->search({ active => 1 }, { order_by => 'name' });

    my $tree = new Tree::Simple('AYALIKE_ROOT', Tree::Simple->ROOT);

    while(my $entry = $entries->next()) {

        my $name = $entry->name();

        if($name =~ /\//) {
            my ($vol, $dir, $file) = File::Spec->splitpath($name);
            my $node = $self->_find_or_create_nodes($tree, $dir);
            $node->addChild(new Tree::Simple($entry));
        } else {
            $tree->addChild(new Tree::Simple($name));
        }
    }

    $self->{'nodes'} = undef;

    return $tree;
}

sub _find_or_create_nodes {
    my $self = shift();
    my $tree = shift();
    my $path = shift();

    my @parts = split(/\//, $path);

    my $accum;
    my $node = $tree;
    # Split the path up into pieces and look for nodes.  Since we are taking
    # willy-nilly paths in no particular order, we have to check each piece
    # and see if we've already created a node.  If we have, we'll use it.  If
    # we haven't then create a new one.  We cache the nodes as we create them
    # in $self->{'nodes'}.
    foreach my $p (@parts) {

        next if $p eq '';

        $accum .= "$p/";
        my $fnode = $self->{'nodes'}->{$accum};
        if($fnode) {
            $node = $fnode;
        } else {
            my $nnode = new Tree::Simple(
                new Ayalike::Directory(name => $p, owner => 'Admin')
            );
            $self->{'nodes'}->{$accum} = $nnode;
            $node->addChild($nnode);
            $node = $nnode;
        }
    }

    return $node;
}

=head2 apply_changeset

Apply the supplied changeset to this Site.

The ChangeSet will iterate over it's Revisions, applying each one.  If a 
revision has already been applied then it will be skipped.  That shouldn't
really happen.

Returns the number of applied Revisions.

=cut
sub apply_changeset {
    my $self = shift();
    my $changeset = shift();

    my $revs = $changeset->revisions();

    my $count = 0;
    while(my $rev = $revs->next()) {
        if($rev->applied()) {
            next;
        }
        $rev->apply();
        $count++;
    }
    return $count;
}

=head2 publish

Publish a site, writing out it's templates into the site's path.  An argument
of a pipeline passed in will pass all the contents through that pipeline.

=cut
sub publish {
    my $self = shift();
    my $pipe = shift();

    my $spath = $self->path();

    my $tree = $self->get_tree_from_entries();

    # With the existing tree in hand, create a new tree for the path of the
    # site, so that CreateDirectoryTree can do all the work for us.
    my @parts = split(/\//, $self->path());

    my $root;
    my $currnode;

    # Foreach piece of the path, create a tree node and add it to it's parent
    foreach my $part (@parts) {
        my $newnode = new Tree::Simple("$part/");
        # If we don't have a currnode, we are making the root node, so
        # skip this
        if($currnode) {
            $currnode->addChild($newnode);
        }
        $currnode = $newnode;

        # This is our first node, so set the root to it.
        unless($root) {
            $root = $newnode;
        }
    }

    # Take all the children from the tree and add them to the new site-path
    # based tree at the bottom 
    $currnode->addChildren(@{ $tree->getAllChildren() });

    my $cd = new Tree::Simple::Visitor::CreateDirectoryTree();

    # CODEREF for making files.  Looks up the name and puts the contents into
    # the file. Prepends the site's path onto the name kept in the entry.
    my $mkfile = sub {
        my $path = shift();

        my $ename;
        # We need to trim off the site's path from the requested file so that
        # we can find it's entry in the database.  If, for some reason, the
        # entry doesn't start with the site's path, we have issues.
        if($path =~ /^$spath\/(.*)/) {
             $ename = $1;
        } else {
            die("Badly constructed tree, path name of '$path'.")
        }

        # Find the requested entry or bail.
        my $entry = $self->entries->find({ name => $ename }, { key => 'entries_site_id_name'});
        die("Unable to find entry for '$ename'!") unless defined($entry);

        # Create the file, filling it with the contents from the database.
        # FIXME: Pipeline
        open(FILE, ">", $path) or die("Unable to create file '$path': $!");

        my $contents = $entry->contents();
        if(defined($pipe)) {
            $contents = $pipe->execute($contents);
        }
        print FILE $contents;

        close(FILE);
    };

    # CODEREF for making directories.  Overrides the existing one, which fails
    # of the directory already exists.  Prepends the site's path onto the name
    # of the directory.
    my $mkdir = sub {
        my $path = shift();

        mkdir($path);
    };

    $cd->setFileHandler($mkfile);
    $cd->setDirectoryHandler($mkdir);
    $root->accept($cd);
}

1;