package Template::Provider::Ayalike;
use strict;

use base qw(Template::Provider);

use LWP::UserAgent;
use Template::Constants;

sub _init {
    my ($self, $options) = @_;

    # die
    $self->{'URL'} = $options->{'URL'};
    $self->{'SITE'} = $options->{'SITE'};
    return $self->SUPER::_init($options);
}

sub _template_content {
    my ($self, $name) = @_;

    if($name =~ /\.\/(.*)/) {
        $name = $1;
    }

    my $ua = new LWP::UserAgent();
    my $resp = $ua->get($self->{'URL'}."/entry/view/".$self->{'SITE'}."/$name");

    # Try and find the template.
    print STDERR $resp->code()." : ".$resp->is_success()."\n";
    unless($resp->is_success()) {
        print STDERR "Declining '$name'.\n";
        return (undef, Template::Constants::STATUS_DECLINED);
    }

    print STDERR ("Loaded template '$name' from Ayalike.\n");

    return wantarray ? ($resp->content(), undef, time()) : $resp->content();
}

sub _template_modified {
    my ($self, $name) = @_;

    print STDERR "template_modified $name\n";

    if(defined($self->{'FOOTIME'})) {
        return $self->{'FOOTIME'};
    }

    $self->{'FOOTIME'} = time();
    return $self->{'FOOTIME'};
}

1;