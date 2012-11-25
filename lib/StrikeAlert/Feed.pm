package StrikeAlert::Feed;

use utf8;

use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;
use Mojo::Util qw( encode decode );
use Encode;
use Mojo::ByteStream 'b';

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
    #TODO: fix rendering
    #$self->render_json( $results );
    $self->render(
            'json' => $results
        );
}

sub test {
    my $self = shift;    

    my $results  = {
                'string1' => 'à',
                'string2' => '\x{E0}', 
                'string3' => b('à')->encode('UTF-8'), 
                'string4' => b('\x{E1}')->encode('UTF-8'), 
            };

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
                if ( $strike->{ $field }->{ $subfield } =~ m/$query/i ) {
                    $strike->{ $field }->{ $subfield } = encode( 'UTF-8', $strike->{ $field }->{ $subfield } );
                    push @filtered_results, $strike;
                }   
                next;
            }
            #regular case
            if ( $strike->{ $field } =~ m/$query/i ) {
                $strike->{ $field } = encode( 'UTF-8', $strike->{ $field } );
                push @filtered_results, $strike;
            }
        }
    }

    return \@filtered_results;
}

1;
