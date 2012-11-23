package Net::DiffBot;

use strict;
use warnings;
use LWP::UserAgent;
use JSON::XS;
use URI::Escape qw(uri_escape);

sub new {
  my ($p, %args) = @_;

  die "No token provided" if (!exists $args{'token'});
  $p = ref($p) || $p;

  my $self = bless {
    %args
  }, $p;

  return $self
}

sub get_data_by_url {
	my ($self, $url, %args) = @_;
	my $endpoint_url = 'http://www.diffbot.com/api/article';
	die "No url provided" if (!$url);

	my @possible_args = qw(callback html dontStripAds tags comments summary);

	my %request_args = (
		'url' => $url,
	);
	for my $arg (@possible_args) {
		if ((exists $args{$arg}) and ($args{$arg}) ) {
			$request_args{$arg} = 'true';
		}
	}
	my $request_url = $self->build_request($endpoint_url, %request_args);
	print $request_url ."\n";
	my $ua = LWP::UserAgent->new();

	my $response = $ua->get($request_url);
	if (!$response->is_success) {
		warn "ERROR with request " . $request_url . " HTTP response" . $response->status_line;
		return undef;
	} else {
		my $data;
		eval {
			$data = decode_json($response->content);
		};
		if ($@) {
			warn "ERROR decoding JSON response";
			return undef;
		}
		return $data;
	}
	
}

sub build_request {
	my ($self, $url, %args) = @_;
	$args{'token'} = $self->{'token'};

	my @keys = sort( grep { defined $args{$_} } keys(%args) );

    if (%args) {
        return  "$url?" . join( '&', map { uri_escape($_,$self->{'uri_unsafe'}) . '=' . uri_escape( $args{$_} ) } @keys );
    } else {
        return $url;
    }	


#	return 'aaa';

	


}
1;
