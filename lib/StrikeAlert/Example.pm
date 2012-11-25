package StrikeAlert::Example;
use Mojo::Base 'Mojolicious::Controller';

use utf8;

# This action will render a template
sub welcome {
    my $self = shift;

    # Render template "example/welcome.html.ep" with message
    $self->render(
        message => 'Welcome to the Mojolicious real-time web framework! á ' );
}

1;
