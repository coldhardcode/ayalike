package Ayalike::Date;
use strict;

=head1 NAME

Ayalike::Date - Date Convenience

=head1 DESCRIPTION

AyalikeAyalike's date convenience module.

=head1 SYNOPSIS

 my $date = Ayalike::Date->new();

=cut

use base('DateTime');

use DateTime::TimeZone;
use DateTime::Format::MySQL;
use DateTime::Format::Strptime;

my $tz = DateTime::TimeZone->new(name => 'local');
my $formatter = DateTime::Format::Strptime->new(
   pattern => '%a, %b %d %Y %I:%M%p %Z'
);

=head1 METHODS

=over 4

=item new()

Creates a new Ayalike::Date object.  Defaults to the instant created.
Compatible with DateTime otherwise.

=cut
sub new {
   my $proto = shift();
   my $class = ref($proto) || $proto;
   my @args = @_;
   my $self = {};

   my $d;
   if(defined($args[0])) {
       $d = DateTime->new(@args);
   } else {
       $d = DateTime->now();
   }
   $d->set_time_zone($tz);
   $d->set_formatter($formatter);

   return bless($d, $class);
}

=item from_epoch($epoch)

Creates a new Ayalike::Date object from epoch.

=cut
sub from_epoch {
   my $proto   = shift();
   my $arg     = shift();

   my $class = ref($proto) || $proto;
   my $self = {};

   my $d = DateTime->from_epoch(epoch => $arg);
   $d->set_time_zone($tz);
   $d->set_formatter($formatter);

   return $d;
}

=item from_mysql($datetime)

Create a DateTime from a MySQL DATETIME column.

=cut
sub from_mysql {
   my $self = shift();
   my $str = shift();

   unless($str) {
       return undef;
   }

   my $dt = DateTime::Format::MySQL->parse_datetime($str);
   if(defined($dt)) {
       $dt->set_time_zone($tz);
       $dt->set_formatter($formatter);
   }

   return bless($dt, 'Ayalike::Date');
}

=item to_mysql()

Output a string suitable for use as a MySQL DATETIME column.

=cut
sub to_mysql {
   my $self = shift();
   my $dt = shift();

   unless($dt) {
       return undef;
   }

   my $to_conv;
   if(ref($self)) {
       $to_conv = $self;
   } else {
       $to_conv = $dt;
   }
   if(defined($to_conv)) {
       return DateTime::Format::MySQL->format_datetime($to_conv);
   }
}

=item from_mysql_date($datetime)

Create a DateTime from a MySQL DATE column.

=cut
sub from_mysql_date {
   my $self = shift();
   my $str = shift();

   unless($str) {
       return undef;
   }

   my $dt = DateTime::Format::MySQL->parse_date($str);
   if(defined($dt)) {
       $dt->set_time_zone($tz);
       $dt->set_formatter($formatter);
   }

   return bless($dt, 'Ayalike::Date');
}

=item to_mysql_date()

Output a string suitable for use as a MySQL DATE column.

=cut
sub to_mysql_date {
   my $self = shift();
   my $dt = shift();

   unless($dt) {
       return undef;
   }

   my $to_conv;
   if(ref($self)) {
       $to_conv = $self;
   } else {
       $to_conv = $dt;
   }
   if($to_conv) {
       return DateTime::Format::MySQL->format_date($to_conv);
   }
}

=item parse_date($date)

Use Date::Manip to try and parse the date.  Returns undef on failure.

=cut
sub parse_date {
   my $self = shift();
   my $date = shift() or return undef;

   print STDERR "USE DateTime::Format::Natural!\n";
   my $d = new Ayalike::Date();

   $d->set_time_zone($tz);
   $d->set_formatter($formatter);

   return bless($d, __PACKAGE__);
}

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@cpan.org>

=head1 SEE ALSO

perl(1)

=cut
1;
