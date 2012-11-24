package Net::DiffBot;

use 5.006;
use strict;
use warnings;
use LWP::UserAgent;
use JSON::XS;
use URI::Escape qw(uri_escape);


=head1 NAME

Net::DiffBot - Interface to the diffbot.com API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module is just an interface for diffbot.com API

Perhaps a little code snippet.

    use Net::DiffBot;

    my $d = Net::DiffBot->new('token' => 'diffbottoken');
	my $page_date = $d->get_data_by_url($url)
    ...



=head1 SUBROUTINES/METHODS

=head2 new

Constructor method, you need to pass the diffbot token 
	
    my $d = Net::DiffBot->new('token' => 'diffbottoken');

=cut

sub new {
  my ($p, %args) = @_;

  die "No token provided" if (!exists $args{'token'});
  $p = ref($p) || $p;

  my $self = bless {
    %args
  }, $p;

  return $self
}

=head2 get_date_by_url

Fetch diffbot data based on the url , along with the url you can set other options

	my $d->get_data_by_url($url, 'tags' => 1, summary => 1)

	Valid flags are: callback, html, dontStripAds, tags, comments, summary
	You can see the use of theses flaga at diffbot.com

=cut

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


}

=head1 AUTHOR

Bruno Martins, C<< <bscmartins at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-diffbot at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-DiffBot>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::DiffBot


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-DiffBot>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-DiffBot>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-DiffBot>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-DiffBot/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Bruno Martins.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Net::DiffBot
