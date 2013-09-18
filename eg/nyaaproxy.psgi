#!/usr/bin/env perl
use strict;
use warnings;
use lib './lib';
use Furl;
use Plack::Builder;
use Plack::Request;
use Plack::Builder;
use Acme::Nyaa;

my $nekonyaaaa = Acme::Nyaa->new();
my $httpobject = Furl->new( 
    'agent' => 'Acme::Nyaa/nyaaproxy/'.$Acme::Nyaa::VERSION, 
    'timeout' => 10
);
my $htresponse = undef;
my $htcontents = undef;
my $servername = undef;
my $requesturl = undef;

builder {
    sub {
        my $env = shift;
        my $url = $env->{'REQUEST_URI'} || $env->{'PATH_INFO'};
        my $req = Plack::Request->new( $env );
        my $res = undef;
        my $err = [ 'Failed to connect' ];
        my $cth = [ 'Content-Type' => 'text/plain' ];
        my $tmp = undef;

        if( length $url ) {

            if( $url =~ m|\A/(https?://)(.+?)/(.*)\z| ) {
                $servername = $1.$2;
                $requesturl = $servername.'/'.$3;

            } else {
                $requesturl = $servername.$url;
            }
            $htresponse = $httpobject->get( $requesturl );

            if( $htresponse->is_success ) {

                $htcontents = $htresponse->content;

                if( $htresponse->content_type =~ m{\Atext/(?:plain|html)} ) {

                    $tmp = [ split( "\n", $htcontents ) ];
                    map { $_ .= "\n" } @$tmp;
                    $htcontents = $nekonyaaaa->straycat( $tmp, 1 );
                }

                return [ 
                    $htresponse->status, 
                    [ 'Content-Type' => $htresponse->content_type ],
                    [ $htcontents ],
                ];

            } else {

                return [ 
                    $htresponse->status, 
                    [ 'Content-Type' => $htresponse->content_type ],
                    [ $htresponse->status_line ],
                ];
            }

        } else {
            $err = [ 'Request URL is empty' ];
            return [ 
                400, 
                [ 'Content-Type' => 'text/plain' ],
                [ 'Request URL is empty' ],
            ];
        }
    };
};

