package StrikeAlert::Tweet;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;
use Mojo::Util 'encode';
use Mojo::ByteStream 'b';
use charnames ':full';

use Data::Dumper;

sub get {
    my $self = shift;
=cut
    # Fresh user agent
    my $ua = Mojo::UserAgent->new;


    my @results;

    my $count = 0;
    # Fetch the latest news about Mojolicious from Twitter
    my $search = 'http://search.twitter.com/search.json?q=Mojolicious';
    for my $tweet ( @{ $ua->get($search)->res->json->{results} } ) {

        last if $count > 3;

        # Tweet text
        my $text = $tweet->{text};

        # Twitter user
        my $user = $tweet->{from_user};

        # Show both
        #push @results, { $count => encode( 'UTF-8', "$text --$user" ) };
        push @results, "é";
        
        $count++;
    }

#    $self->render('text', join(', ', @results));
=cut

#    $self->render('text',  b("\N{LATIN SMALL LETTER A WITH ACUTE}"));

    $self->render('json', { 0 => b("\N{LATIN SMALL LETTER A WITH ACUTE}" )->to_string });

}

1;
