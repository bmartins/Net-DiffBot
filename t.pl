#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Net::DiffBot;
my $url ='http://www.perlhowto.com/encode_and_decode_url_strings';
my $d = Net::DiffBot->new( token => $ENV{'diffbot_token'});
my $data = $d->get_data_by_url($url, 'tags' => 1, 'summary' => 1);

print Dumper $data;




