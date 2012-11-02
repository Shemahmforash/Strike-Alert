package StrikeAlert::Feed;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;
use Mojo::Util 'encode';

use Data::Dumper;

# Fresh user agent
my $ua = Mojo::UserAgent->new;

my $source = 'http://hagreve.com/api/v1/strikes';

sub fetch {
    my $self = shift; 

    #fetch strike results
    my $json    = $ua->get( $source );
    my $results = $json->res->json;

    #filter the strike results by the params passed
    $results = $self->_filter( $results );

    #render json
    $self->render_json( $results );

}

#filter the json results by a particular string in a particular field
sub _filter {
    my $self    = shift;
    my $results = shift;

    my $query = $self->param('query');

    my @fields;
    for my $field ( split (',', $self->param('field') || 'description' )) {
        push @fields, $field;
    }

    #return results unaltered unless both params defined
    return $results unless $query && scalar @fields;

    #filter using field and query params
    my @filtered_results;
    for my $strike ( @{ $results } ) {
        for my $field ( @fields ) {
            #in some cases, must analyse second level
            if ( $field =~ /company/ || $field =~ /submitter/ ) {
                my ( $field, $subfield ) = split ':', $field;
                push @filtered_results, $strike
                    if $strike->{ $field }->{ $subfield } =~ m/$query/i;   
                next;
            }
            #regular case
            push @filtered_results, $strike
                if $strike->{ $field } =~ m/$query/i;   
        }
    }

    return \@filtered_results;
}

1;
