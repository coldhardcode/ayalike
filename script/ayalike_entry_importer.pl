#!/usr/bin/perl
use strict;

use lib 'lib/';

use Config::Any;
use Data::Dumper;
use File::Find;
use File::Spec;
use Getopt::Long;

use Ayalike::Date;
use Ayalike::Schema;

my %opt;
GetOptions(
    'dir:s' => \$opt{'directory'},
    'ext:s' => \$opt{'extension'},
    'p:i' => \$opt{'p'},
    'site:i'=> \$opt{'site'},
    'test'  => \$opt{'test'},
    'help'  => \$opt{'help'}
);

unless($opt{'directory'}) {
    $opt{'help'} = 1;
}

if($opt{'help'}) {
    my $usage = "Usage ayalike_entry_importer.pl [options]\n"
        ."\t--dir directory-to-search\n"
        ."\t--ext extension of files to import\n"
        ."\t--p number directories to trim off the prefix\n"
        ."\t--site site id to import into\n"
        ."\t--test\n"
        ."\t--help this text\n";
    print $usage;
    exit();
}

# Use the existing ConfigLoader stuff to get this info

my @templates;
my $ext = $opt{'extension'};
find(
    sub {
        my $file = $_;
        if(-f $file && -r $file && ($file =~ /\.$ext$/)) {
            my ($vol, $dir, $file) = File::Spec->splitpath($File::Find::name);
            my @dirs = File::Spec->splitdir($dir);
            # Remove p - 1 (zero based!) directories from the path
            my @result = @dirs[($opt{'p'}-1)..$#dirs];
            my $fdir = join('/', @result);
            $fdir .= "$file";
            push(@templates, {
                entry   => $fdir,
                path    => $File::Find::name,
            });
        }
    },
    $opt{'directory'}
);

if($opt{'test'}) {
    print Dumper(\@templates);
    exit();
}

my $config = Config::Any->load_files({
    files => [ 'ayalike.yml' ],
    use_ext => 1
});

my $schema = Ayalike::Schema->connection(@{
    $config->[0]->{'ayalike.yml'}->{'Model::DBIC'}->{'connect_info'}
});

my $site = $schema->resultset('Site')->find($opt{'site'});
unless($site) {
    die('Could not find site: '.$opt{'site'});
}

my $now = new Ayalike::Date();

$schema->txn_begin();
eval {
    foreach my $ent (@templates) {

        open(FILE, $ent->{'path'});
        my @lines;
        while(<FILE>) {
            push(@lines, $_);
        }
        close(FILE);

        # print $ent->{'entry'}."\n";
        # print join('', @lines);

        $site->add_to_entries({
           name     => $ent->{'entry'},
           active   => 1,
           contents => join('', @lines),
           date_created => $now,
           date_last_modified => $now
        });
    }
};

if($@) {
    die('Failed inserting entries: '.$@);
    eval { $schema->txn_rollback(); }
}

$schema->txn_commit();