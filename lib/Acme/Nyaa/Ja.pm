package Acme::Nyaa::Ja;
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

sub cat
{
	my $class = shift;
	my $text0 = shift;
	my $text1 = undef;
	my $text2 = undef;
	my $bless = ref $text0;

	return q() if( $bless ne '' && $bless ne 'SCALAR' );
	$text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $text1;

	my $cname = __PACKAGE__->_reckon( \$text1 ) || 'utf8';
	my $uflag = $cname eq 'utf8' ? utf8::is_utf8 $text1 : undef;

	# return $text1 unless $cname;
	eval { $text2 =  __PACKAGE__->_toutf8( $text1, $cname, $uflag ); };
	return $text1 if $@;

	$text2 =~ s{($RxPeriod)}{$1$Separator}g;
	$text2 .= $Separator unless $text2 =~ m{$Separator};

	my $sizeh = scalar @$HiraganaTails;
	my $sizek = scalar @$KatakanaTails;
	my $index = 0;
	my $gauge = 0;
	my $chomp = 0;
	my $lines = [ split( $Separator, $text2 ) ];

	foreach my $e ( @$lines )
	{
		next if $e =~ m/\A$RxPeriod\s*\z/;
		next if $e =~ m/$RxEndOfList\s*\z/;
		next if grep { $e =~ m/\A$_\s*/ } @$DoNotBecomeCat;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$HiraganaTails;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$KatakanaTails;
		next if grep { $e =~ m/$_$RxEndOfSentence?\s*\z/ } @$HiraganaTails;
		next if grep { $e =~ m/$_$RxEndOfSentence?\s*\z/ } @$KatakanaTails;
		next if grep { $e =~ m/$_\s*\z/ } @$FightingCats;

		next if $e =~ m{\A[\x20-\x7E]+\z};

		# ひらがな、またはカタカナが入ってないなら次へ
		next unless $e =~ m{[\p{InHiragana}\p{InKatakana}]+};

		# 「ね」の後ろにニャーがあると猫が喋りにくそう
		next if $e =~ m{[ねネ]$RxPeriod?\s*\z};

		$chomp = chomp $e;

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
			$index = int rand $sizek;
			$e =~ s/($RxPeriod)(\s*)\z/$KatakanaTails->[ $index ]$1$2/;
		}
		elsif( $e =~ m/\p{InKatakana}$RxPeriod\s*\z/ )
		{
			$index = int rand $sizeh;
			$e =~ s/($RxPeriod)(\s*)\z/$HiraganaTails->[ $index ]$1$2/;
		}
		elsif( $e =~ m/\p{InCJKUnifiedIdeographs}$RxPeriod?\s*\z/ )
		{
			$index = int rand $sizeh;
			$gauge = int rand scalar @$Copulae;
			$e =~ s/($RxPeriod?)(\s*)\z/$Copulae->[ $gauge ]$KatakanaTails->[ $index ]$1$2/;
		}
		else
		{
			if( $e =~ m/($RxEndOfSentence)\s*\z/ )
			{
				# ... => ニャー..., ! => ニャ!
				my $eos = $1;
				if( $e =~ m/\p{InKatakana}$RxEndOfSentence\s*\z/ )
				{
					$index = int rand( $sizeh / 2 );
					$e =~ s/$RxEndOfSentence/$HiraganaTails->[ $index ]$eos/g;
				}
				elsif( $e =~ m/\p{InHiragana}$RxEndOfSentence\s*\z/ )
				{
					$index = int rand( $sizek / 2 );
					$e =~ s/$RxEndOfSentence/$KatakanaTails->[ $index ]$eos/g;
				}
				else
				{
					$index = int rand( $sizek / 2 );
					$gauge = int rand( scalar @$Copulae );
					$e =~ s/$RxEndOfSentence/$Copulae->[ $gauge ]$KatakanaTails->[ $index ]$eos/g;
				}
			}
			elsif( $e =~ m/$RxConversation\s*\z/ )
			{
				# 0.5の確率で会話の後ろで猫が喧嘩をする
				if( $e =~ m/\A(.*$RxConversation[ ]*)($RxConversation.*)\s*\z/ )
				{
					$index = int rand scalar @$FightingCats;
					$e = $1.$FightingCats->[ $index ].$2 if int(rand(10)) % 2;
				}
				$index = int rand scalar @$FightingCats;
				$e .= $FightingCats->[ $index ] if int(rand(10)) % 2;
			}
			else
			{
				$index = int rand $sizek;

				if( $e =~ m/[0-9\p{Latin}]\s*\z/ )
				{
					$gauge = int rand scalar @$Copulae;
					$e =~ s/(\s*?)\z/ $Copulae->[ $gauge ]$KatakanaTails->[ $index ]$1/;
				}
				elsif( $e =~ m/\p{InKatakana}\s*\z/ )
				{
					$e =~ s/(\s*?)\z/$HiraganaTails->[ $index ]$1/;
				}
				else
				{
					$e =~ s/(\s*?)\z/$KatakanaTails->[ $index ]$1/;
				}
			}
		}

		$e .= qq(\n) if $chomp;

	} # End of foreach(@$lines)

	return __PACKAGE__->_utf8to( join( '', @$lines ), $cname, $uflag );
}

sub neko
{
	my $class = shift;
	my $text0 = shift;
	my $text1 = undef;
	my $text2 = undef;
	my $bless = ref $text0;

	return q() if( $bless ne '' && $bless ne 'SCALAR' );
	$text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $text1;

	my $cname = __PACKAGE__->_reckon( \$text1 ) || 'utf8';
	my $uflag = $cname eq 'utf8' ? utf8::is_utf8 $text1 : undef;

	eval { $text2 = __PACKAGE__->_toutf8( $text1, $cname, $uflag ); };
	return $text1 if $@;

	my $map = {
		'神' => 'ネコ',
	};

	foreach my $e ( keys %$map )
	{
		next unless $text2 =~ m{$e};
		my $f = $map->{ $e };

		$text2 =~ s{\A[$e]\z}{$f};
		$text2 =~ s{\A[$e](\p{InHiragana})}{$f$1};
		$text2 =~ s{\A[$e](\p{InKatakana})}{$f$1};
		$text2 =~ s{(\p{InHiragana})[$e](\p{InHiragana})}{$1$f$2}g;
		$text2 =~ s{(\p{InHiragana})[$e](\p{InKatakana})}{$1$f$2}g;
		$text2 =~ s{(\p{InKatakana})[$e](\p{InKatakana})}{$1$f$2}g;
		$text2 =~ s{(\p{InKatakana})[$e](\p{InHiragana})}{$1$f$2}g;
		$text2 =~ s{(\p{InHiragana})[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
		$text2 =~ s{(\p{InKatakana})[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
	}

	return __PACKAGE__->_utf8to( $text2, $cname, $uflag );
}

sub _reckon
{
	my $class = shift;
	my $text0 = shift;
	my $bless = ref $text0;

	my $text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $text1;

	my $guess = Encode::Guess->guess( $text1 );
	return q() unless ref $guess;
	return $guess->name;
}

sub _toutf8
{
	my $class = shift;
	my $text0 = shift // return q();
	my $cname = shift || __PACKAGE__->_reckon( \$text0 );
	my $uflag = shift // 0;

	return $text0 unless $cname;
	Encode::from_to( $text0, $cname, 'utf8' ) if $cname ne 'utf8';
	$uflag = utf8::is_utf8($text0);
	utf8::decode $text0 unless $uflag;

	return $text0;
}

sub _utf8to
{
	my $class = shift;
	my $text0 = shift // return q();
	my $cname = shift || return $text0;
	my $uflag = shift // 0;

	utf8::encode $text0 if( $uflag == 0 && utf8::is_utf8 $text0 );
	Encode::from_to( $text0, 'utf8', $cname ) if $cname ne 'utf8';

	return $text0;
}

1;

__END__
=encoding utf8

=head1 NAME

Acme::Nyaa - Convert texts like which a cat is talking in Japanese

=head1 SYNOPSIS

  use Acme::Nyaa;

  my $kijitora = Acme::Nyaa->new( 'language' => 'ja' );

  print $kijitora->cat( \'猫がかわいい。' ); # => 猫がかわいいニャー。
  print $kijitora->neko( \'神と和解せよ' ); # => ネコと和解せよ


=head1 DESCRIPTION
  
  Acme::Nyaa is a converter which translate Japanese texts to texts
  like which a cat talking.

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
L<Acme::Nyaa>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
