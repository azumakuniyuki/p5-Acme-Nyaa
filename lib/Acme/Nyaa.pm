package Acme::Nyaa;
use strict;
use warnings;
use utf8;
use 5.010000;
use Module::Load;

use version; our $VERSION = qv('0.0.3');
my $Default = 'ja';

sub new
{
	my $class = shift;
	my $argvs = { @_ };

	return $class if ref $class eq __PACKAGE__;
	$argvs->{'objects'} = [];
	$argvs->{'language'} ||= $Default;
	$argvs->{'loaded-languages'} = [];
	$argvs->{'objectid'} = int rand 2**24;

	my $nyaan = bless $argvs, __PACKAGE__;
	my $klass = $nyaan->loadmodule( $argvs->{'language'} );
	my $this1 = $nyaan->findobject( $klass, 1 );

	return $nyaan;
}

sub language
{
	my $self = shift;
	my $lang = shift // $self->{'language'};

	$self->{'language'} = $lang;
	return $self->{'language'};
}

sub objects
{
	my $self = shift;
	$self->{'objects'} ||= [];
	return $self->{'objects'};
}

sub cat
{
	my $self = shift;
	my $text = shift // return q();
	my $argv = { @_ };
	my $lang = $argv->{'language'} || $self->{'language'};

	my $referclass = $self->loadmodule( $lang );
	my $nekoobject = undef;

	return $text unless length $referclass;
	$nekoobject = $self->findobject( $referclass, 1 );
	return $nekoobject->cat( $text );
}

sub neko
{
	my $self = shift;
	my $text = shift // return q();
	my $argv = { @_ };
	my $lang = $argv->{'language'} || $self->{'language'};

	my $referclass = $self->loadmodule( $lang );
	my $nekoobject = undef;

	return $text unless length $referclass;
	$nekoobject = $self->findobject( $referclass, 1 );
	return $nekoobject->neko( $text );
}

sub nyaa
{
	my $self = shift;
	my $argv = { @_ };
	my $lang = $argv->{'language'} || $self->{'language'};

	my $referclass = $self->loadmodule( $lang );
	my $nekoobject = undef;
	return q() unless length $referclass;

	$nekoobject = $self->findobject( $referclass, 1 );
	return $nekoobject->nyaa;
}

sub loadmodule
{
	my $self = shift;
	my $lang = shift;
	my $list = $self->{'loaded-languages'};

	my $referclass = __PACKAGE__.'::'.ucfirst( lc $lang );
	my $alterclass = __PACKAGE__.'::'.ucfirst( $Default );

	return q() unless length $lang;
	return $referclass if( grep { lc $lang eq $_ } @$list );

	eval { 
		Module::Load::load $referclass; 
		push @$list, lc $lang;
	};

	return $referclass unless $@;
	return $alterclass if( grep { 'ja' eq $_ } @$list );

	Module::Load::load $alterclass;
	push @$list, $Default;
	return $alterclass;
}

sub findobject
{
	my $self = shift;
	my $name = shift;
	my $new1 = shift || 0;
	my $this = undef;
	my $objs = $self->{'objects'} || [];

	return unless length $name;

	foreach my $e ( @$objs )
	{
		next unless ref($e) eq $name;
		$this = $e;
	}
	return $this if ref $this;
	return unless $new1;

	$this = $name->new;
	push @$objs, $this;
	return $this;
}


1;
__END__

=encoding utf8

=head1 NAME

Acme::Nyaa - Convert texts like which a cat is talking in Japanese

=head1 SYNOPSIS

	use Acme::Nyaa;
	my $kijitora = Acme::Nyaa->new;

	print $kijitora->cat( \'猫がかわいい。' );	# => 猫がかわいいニャー。
	print $kijitora->neko( \'神と和解せよ' );	# => ネコと和解せよ


=head1 DESCRIPTION
  
Acme::Nyaa is a converter which translate Japanese texts to texts like which a cat talking.
Language modules are available only Japanese (L<Acme::Nyaa::Ja>) for now.

Nyaa is C<ニャー>, Cats living in Japan meows C<nyaa>.

=head1 CLASS METHODS

=head2 B<new>

new() is a constructor of Acme::Nyaa

=head1 INSTANCE METHODS

=head2 B<cat>

cat() is a converter that appends string C<ニャー> at the end of each sentence.

=head2 B<neko>

neko() is a converter that replace a noun with C<ネコ>.

=head2 B<nyaa>

nyaa() returns string: C<ニャー>.

=head1 REPOSITORY

https://github.com/azumakuniyuki/p5-Acme-Nyaa

=head2 INSTALL FROM REPOSITORY

	% sudo cpanm Module::Install
	% cd /usr/local/src
	% git clone git://github.com/azumakuniyuki/p5-Acme-Nyaa.git
	% cd ./p5-Acme-Nyaa
	% perl Makefile.PL && make && make test && sudo make install

=head1 AUTHOR

azumakuniyuki E<lt>perl.org [at] azumakuniyuki.orgE<gt>

=head1 SEE ALSO

L<Acme::Nyaa::Ja> - Japanese module for Acme::Nyaa

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

