package Acme::Nyaa::Ja;
use parent 'Acme::Nyaa';
use strict;
use warnings;
use utf8;
use Encode;
use Encode::Guess qw(shift-jis euc-jp 7bit-jis);;

my $RxComma = qr/[、(?:,\s+)]/;
my $RxPeriod = qr/[。]/;
my $RxEndOfList = qr#[）)-=+|}＞>/:;"'`\]]#;
my $RxConversation = qr/[「『].+[」』]/;
my $RxEndOfSentence = qr/(?:[!！?？…]+|[.]{2,}|[。]{2,}|[、]{2,}|[,]{2,})/;

my $Cats = [ '猫', 'ネコ', 'ねこ' ];
my $Separator = qq(\x1f\x1f\x1f);
my $HiraganaNya = 'にゃ';
my $KatakanaNya = 'ニャ';
my $FightingCats = [
	'「マーオ」',
	'「マーオ!」',
	'「マーーオ」',
	'「マーーオ!」',
	'「マーーーオ!!」',
	'「マーーーーオ!!!」',
];
my $Copulae = [ 'だ', 'です', 'である', 'どす', 'かもしれない', 'らしい', 'ようだ' ];
my $HiraganaTails = [ 
	'にゃ', 'にゃー', 'にゃ〜', 'にゃーーーー!', 'にゃん', 'にゃーん', 'にゃ〜ん', 
	'にゃー!', 'にゃーーー!!', 'にゃーー!',
];
my $KatakanaTails = [
	'ニャ', 'ニャー', 'ニャ〜', 'ニャーーーー!', 'ニャん', 'ニャーん', 'ニャ〜ん',
	'ニャー!', 'ニャーーー!!', 'ニャーー!', 
];
my $DoNotBecomeCat = [
	# See http://ja.wikipedia.org/wiki/モーニング娘。
	'モーニング娘。',
	'カントリー娘。',
	'ココナッツ娘。',
	'ミニモニ。',
	'エコモニ。',
	'ハロー!モーニング。',
	'エアモニ。',
	'モーニング刑事。',
	'モー娘。',
];

sub new
{
	my $class = shift;
	my $argvs = { @_ };

	return $class if ref $class eq __PACKAGE__;
	$argvs->{'language'} = 'ja';
	return bless $argvs, __PACKAGE__;
}

sub language
{
	my $self = shift;

	$self->{'language'} ||= 'ja';
	return $self->{'language'};
}

sub object
{
	my $self = shift;
	return __PACKAGE__->new unless ref $self;
	return $self;
}
*objects = *object;
*findobject = *object;

sub cat
{
	my $self = shift;
	my $text = shift;

	my $beinputted = undef;
	my $utf8string = undef;
	my $referenced = ref $text;
	my $guessedenc = undef;
	my $wellformed = undef;

	return q() if( $referenced ne '' && $referenced ne 'SCALAR' );
	$beinputted = $referenced eq 'SCALAR' ? $$text : $text;
	return q() unless length $beinputted;

	$guessedenc = __PACKAGE__->reckon( \$beinputted ) || 'utf8';
	$wellformed = $guessedenc eq 'utf8' ? utf8::is_utf8 $beinputted : undef;

	eval { $utf8string =  __PACKAGE__->toutf8( $beinputted, $guessedenc, $wellformed ); };
	return $beinputted if $@;

	$utf8string =~ s{($RxPeriod)}{$1$Separator}g;
	$utf8string .= $Separator unless $utf8string =~ m{$Separator};

	my $hiralength = scalar @$HiraganaTails;
	my $katalength = scalar @$KatakanaTails;
	my $writingset = [ split( $Separator, $utf8string ) ];
	my $haschomped = 0;
	my ( $r1,$r2 ) = 0;

	foreach my $e ( @$writingset )
	{
		next if $e =~ m/\A$RxPeriod\s*\z/;
		next if $e =~ m/$RxEndOfList\s*\z/;
		next if grep { $e =~ m/\A$_\s*/ } @$DoNotBecomeCat;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$HiraganaTails;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$KatakanaTails;
		next if grep { $e =~ m/$_$RxEndOfSentence?\s*\z/ } @$HiraganaTails;
		next if grep { $e =~ m/$_$RxEndOfSentence?\s*\z/ } @$KatakanaTails;
		next if grep { $e =~ m/$_\s*\z/ } @$FightingCats;

		# Do not convert if the string contain only ASCII characters.
		next if $e =~ m{\A[\x20-\x7E]+\z};

		# ひらがな、またはカタカナが入ってないなら次へ
		next unless $e =~ m{[\p{InHiragana}\p{InKatakana}]+};

		# Cats may be hard to speak a word which ends with a character 'ね'.
		# 「ね」の後ろにニャーがあると猫が喋りにくそう
		next if $e =~ m{[ねネ]$RxPeriod?\s*\z};

		$haschomped = chomp $e;

		if( $e =~ m/な$RxPeriod?\s*\z/ )
		{
			# な => にゃー
			$e =~ s/な($RxPeriod?)(\s*)\z/$HiraganaNya$1$2/;
		}
		elsif( $e =~ m/ナ$RxPeriod?\s*\z/ )
		{
			# ナ => ニャー
			$e =~ s/ナ($RxPeriod?)(\s*)\z/$HiraganaNya$1$2/;
		}
		elsif( $e =~ m/\p{InHiragana}$RxPeriod\s*\z/ )
		{
			$r1 = int rand $katalength;
			$e =~ s/($RxPeriod)(\s*)\z/$KatakanaTails->[ $r1 ]$1$2/;
		}
		elsif( $e =~ m/\p{InKatakana}$RxPeriod\s*\z/ )
		{
			$r1 = int rand $hiralength;
			$e =~ s/($RxPeriod)(\s*)\z/$HiraganaTails->[ $r1 ]$1$2/;
		}
		elsif( $e =~ m/\p{InCJKUnifiedIdeographs}$RxPeriod?\s*\z/ )
		{
			$r1 = int rand $hiralength;
			$r2 = int rand scalar @$Copulae;
			$e =~ s/($RxPeriod?)(\s*)\z/$Copulae->[ $r2 ]$KatakanaTails->[ $r1 ]$1$2/;
		}
		else
		{
			if( $e =~ m/($RxEndOfSentence)\s*\z/ )
			{
				# ... => ニャー..., ! => ニャ!
				my $eos = $1;
				if( $e =~ m/\p{InKatakana}$RxEndOfSentence\s*\z/ )
				{
					$r1 = int rand( $hiralength / 2 );
					$e =~ s/$RxEndOfSentence/$HiraganaTails->[ $r1 ]$eos/g;
				}
				elsif( $e =~ m/\p{InHiragana}$RxEndOfSentence\s*\z/ )
				{
					$r1 = int rand( $katalength / 2 );
					$e =~ s/$RxEndOfSentence/$KatakanaTails->[ $r1 ]$eos/g;
				}
				else
				{
					$r1 = int rand( $katalength / 2 );
					$r2 = int rand( scalar @$Copulae );
					$e =~ s/$RxEndOfSentence/$Copulae->[ $r2 ]$KatakanaTails->[ $r1 ]$eos/g;
				}
			}
			elsif( $e =~ m/$RxConversation\s*\z/ )
			{
				# 0.5の確率で会話の後ろで猫が喧嘩をする
				if( $e =~ m/\A(.*$RxConversation[ ]*)($RxConversation.*)\s*\z/ )
				{
					$r1 = int rand scalar @$FightingCats;
					$e = $1.$FightingCats->[ $r1 ].$2 if int(rand(10)) % 2;
				}
				$r1 = int rand scalar @$FightingCats;
				$e .= $FightingCats->[ $r1 ] if int(rand(10)) % 2;
			}
			else
			{
				$r1 = int rand $katalength;

				if( $e =~ m/[0-9\p{Latin}]\s*\z/ )
				{
					$r2 = int rand scalar @$Copulae;
					$e =~ s/(\s*?)\z/ $Copulae->[ $r2 ]$KatakanaTails->[ $r1 ]$1/;
				}
				elsif( $e =~ m/\p{InKatakana}\s*\z/ )
				{
					$e =~ s/(\s*?)\z/$HiraganaTails->[ $r1 ]$1/;
				}
				else
				{
					$e =~ s/(\s*?)\z/$KatakanaTails->[ $r1 ]$1/;
				}
			}
		}

		$e .= qq(\n) if $haschomped;

	} # End of foreach(@$writingset)

	return __PACKAGE__->utf8to( join( '', @$writingset ), $guessedenc, $wellformed );
}

sub neko
{
	my $self = shift;
	my $text = shift;

	my $beinputted = undef;
	my $utf8string = undef;
	my $referenced = ref $text;
	my $guessedenc = undef;
	my $wellformed = undef;
	my $nounstable = undef;

	return q() if( $referenced ne '' && $referenced ne 'SCALAR' );
	$beinputted = $referenced eq 'SCALAR' ? $$text : $text;
	return q() unless length $beinputted;

	$guessedenc = __PACKAGE__->reckon( \$beinputted ) || 'utf8';
	$wellformed = $guessedenc eq 'utf8' ? utf8::is_utf8 $beinputted : undef;

	eval { $utf8string = __PACKAGE__->toutf8( $beinputted, $guessedenc, $wellformed ); };
	return $beinputted if $@;

	$nounstable = {
		'神' => 'ネコ',
	};

	foreach my $e ( keys %$nounstable )
	{
		next unless $utf8string =~ m{$e};
		my $f = $nounstable->{ $e };

		$utf8string =~ s{\A[$e]\z}{$f};
		$utf8string =~ s{\A[$e](\p{InHiragana})}{$f$1};
		$utf8string =~ s{\A[$e](\p{InKatakana})}{$f$1};
		$utf8string =~ s{(\p{InHiragana})[$e](\p{InHiragana})}{$1$f$2}g;
		$utf8string =~ s{(\p{InHiragana})[$e](\p{InKatakana})}{$1$f$2}g;
		$utf8string =~ s{(\p{InKatakana})[$e](\p{InKatakana})}{$1$f$2}g;
		$utf8string =~ s{(\p{InKatakana})[$e](\p{InHiragana})}{$1$f$2}g;
		$utf8string =~ s{(\p{InHiragana})[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
		$utf8string =~ s{(\p{InKatakana})[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
	}

	return __PACKAGE__->utf8to( $utf8string, $guessedenc, $wellformed );
}

sub nyaa
{
	my $self = shift;
	my $data = shift || q();
	my $text = ref $data ? $$data : $data;
	my $nyaa = [];

	push @$nyaa, @$KatakanaTails, @$HiraganaTails;
	return $text.$nyaa->[ int rand( scalar @$nyaa ) ];
}

sub reckon
{
	my $class = shift;
	my $text0 = shift;

	my $referenced = ref $text0;
	my $beinputted = $referenced eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $beinputted;

	my $guessedenc = Encode::Guess->guess( $beinputted );
	return q() unless ref $guessedenc;
	return $guessedenc->name;
}

sub toutf8
{
	my $class = shift;
	my $text0 = shift // return q();
	my $guess = shift || __PACKAGE__->reckon( \$text0 );
	my $uflag = shift // 0;

	return $text0 unless $guess;

	Encode::from_to( $text0, $guess, 'utf8' ) if $guess ne 'utf8';
	$uflag = utf8::is_utf8($text0);
	utf8::decode $text0 unless $uflag;
	return $text0;
}

sub utf8to
{
	my $class = shift;
	my $text0 = shift // return q();
	my $guess = shift || return $text0;
	my $uflag = shift // 0;

	utf8::encode $text0 if( $uflag == 0 && utf8::is_utf8 $text0 );
	Encode::from_to( $text0, 'utf8', $guess ) if $guess ne 'utf8';
	return $text0;
}

1;

__END__
=encoding utf8

=head1 NAME

Acme::Nyaa - Convert texts like which a cat is talking in Japanese

=head1 SYNOPSIS

	use Acme::Nyaa::Ja;
	my $kijitora = Acme::Nyaa::Ja->new();

	# the following code is equivalent to the above.

	use Acme::Nyaa;
	my $kijitora = Acme::Nyaa->new( 'language' => 'ja' );


	print $kijitora->cat( \'猫がかわいい。' );	# => 猫がかわいいニャー。
	print $kijitora->neko( \'神と和解せよ' );	# => ネコと和解せよ

=head1 DESCRIPTION
  
Acme::Nyaa is a converter which translate Japanese texts to texts like which a cat talking.
Language modules are available only Japanese (L<Acme::Nyaa::Ja>) for now.

=head1 CLASS METHODS

=head2 B<new()>

new() is a constructor of Acme::Nyaa::Ja

=head1 INSTANCE METHODS

=head2 B<cat( I<\$text> )>

cat() is a converter that appends string C<ニャー> at the end of each sentence.

=head2 B<neko( I<\$text> )>

neko() is a converter that replace a noun with C<ネコ>.

=head2 B<nyaa( [I<\$text>] )>

nyaa() returns string: C<ニャー>.

=head1 AUTHOR

azumakuniyuki E<lt>perl.org [at] azumakuniyuki.orgE<gt>

=head1 SEE ALSO

L<Acme::Nyaa>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

