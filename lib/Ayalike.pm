package Ayalike;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use Catalyst qw/
                -Debug
                ConfigLoader
                Authentication
                Authorization::Roles
                FormValidator
                I18N
                Session
                Session::Store::File
                Session::State::Cookie
                Static::Simple
                Unicode
              /;

our $VERSION = '0.01';

=head1 NAME

Ayalike - Catalyst-based Content Management System

=head1 SYNOPSIS

    edit ayalike.yml and configure your database
    
    script/ayalike_makedb.pl

    script/ayalike_server.pl
    
    http://localhost:3000

=head1 DESCRIPTION

Ayalike is a content management system.  It's job is to store content, allow
editing and versioning of that content, and provide a means to 'publish' the
content.

Many content management systems force developers to recast their applications
into a format, language or medium that is acceptable to the CMS or, worse yet,
they purport to contain all the functionality needed to build your application.

Ayalike doesn't know how your application works.  You can look at that as a
benefit or a detriment.  It won't build your site for you, but it also won't
get in your way.

Ayalike provides the following:

  * multiple sites
  * multiple users
  * database agnostic
  * template system agnostic
  * authorization / authentication agnostic
  * role-based authorization of various abilities
  * directory-style template management
  * configurable processing or filtering
  * versioning and history of all changes (w/diffs)
  * publishing of changes
  * wiki style previewing
 
=head2 METHODS

=over 4

=cut
__PACKAGE__->config( name => 'Ayalike' );

# Start the application
__PACKAGE__->setup;

sub _mark_error_vars {
    my $self = shift();

    # when Data::FormValidator::Results->invalid is called in
    # scalar context, it returns a hashref whose key/value pairs
    # define the field names and the constraint names for which
    # failure in validation occurred.  we squash this data
    # structure from a hash of arrays into an array of scalars,
    # where each field name has the name of any failed named
    # constraint appended to it, separated by an underscore.
    #
    # any unnamed constraints implicitly default to the field name

    my $href = $self->form->invalid();

    my @invalid = map {
        my $field = $_;
        map { $field . (ref $_ eq '' ? '_' . $_ : '') } @{ $href->{$field} };
    } keys %{ $href };

    # set stash variables for missing and invalid form items

    foreach my $var ($self->form->missing()) {
        #$c->log->warn("FORM: $var is missing!");
        $self->stash->{"$var\_class"} = 'missing';
        $self->stash->{"$var\_missing"} = 1;
    }
    foreach my $var (@invalid) {
        #$c->log->warn("FORM: $var is invalid!");
        $self->stash->{"$var\_class"} = 'invalid';
        $self->stash->{"$var\_invalid"} = 1;
    }
}

=item check_form

Validates the form.  Returns true if there were no errors.  If errors are
encountered then copy_vars_to_stash and mark_error_vars are called and 0 is
returned.

=cut
sub check_form {
    my $self = shift();

    if($self->form->has_invalid() || $self->form->has_missing()) {
        $self->_mark_error_vars();
        return 0;
    }
    return 1;
}

=back

=head1 SEE ALSO

L<Ayalike::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Cory Watson <gphat@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
