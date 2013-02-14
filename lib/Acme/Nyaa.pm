package Acme::Nyaa;
use strict;
use warnings;
use utf8;
use 5.010000;
use Module::Load;

use version; our $VERSION = qv('0.0.3');

sub new
{
	my $class = shift;
	my $argvs = { @_ };

	$argvs->{'language'} ||= 'ja';
	$argvs->{'loaded-languages'} = [];

	return bless $argvs, __PACKAGE__;
}

sub cat
{
	my $self = shift;
	my $text = shift // return q();
	my $argv = { @_ };
	my $lang = $argv->{'language'} || $self->{'language'};

	my $referclass = $self->loadmodule( $lang );

	return $text unless length $referclass;
	return $referclass->cat( $text );
}

sub neko
{
	my $self = shift;
	my $text = shift // return q();
	my $argv = { @_ };
	my $lang = $argv->{'language'} || $self->{'language'};

	my $referclass = $self->loadmodule( $lang );

	return $text unless length $referclass;
	return $referclass->neko( $text );
}

sub loadmodule
{
	my $self = shift;
	my $lang = shift;
	my $list = $self->{'loaded-languages'};

	my $referclass = __PACKAGE__.'::'.ucfirst( lc $lang );
	my $alterclass = __PACKAGE__.'::Ja';

	return q() unless length $lang;
	return $referclass if( grep { lc $lang eq $_ } @$list );

	eval { 
		Module::Load::load $referclass; 
		push @$list, lc $lang;
	};

	return $referclass unless $@;
	return $alterclass if( grep { 'ja' eq $_ } @$list );

	Module::Load::load $alterclass;
	push @$list, 'ja';
	return $alterclass;
}


1;
__END__
=encoding utf8

=head1 NAME

Acme::Nyaa - Convert texts like which a cat is talking in Japanese

=head1 SYNOPSIS

  use Acme::Nyaa;

  my $kijitora = Acme::Nyaa->new;

  print $kijitora->cat( \'猫がかわいい。' ); # => 猫がかわいいニャー。
  print $kijitora->neko( \'神と和解せよ' ); # => ネコと和解せよ


=head1 DESCRIPTION
  
  Acme::Nyaa is a converter which translate Japanese texts to texts
  like which a cat talking.

  Nyaa is "ニャー", Cats living in Japan meows "nyaa".

=head1 METHODS

=over

=item new
  new() is a constructor of Acme::Nyaa

=item cat
  cat() is a converter that appends string "ニャー" at the end of
  each sentence.

=item neko
  neko() is a converter that replace a noun with 'ネコ'.

=back

=head1 AUTHOR

azumakuniyuki E<lt>perl.org [at] azumakuniyuki.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
