package MIME::Base91;

require 5.005_62;
use strict;
use warnings;

my @b91_enctab = (
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
	'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '#', '$',
	'%', '&', '(', ')', '*', '+', ',', '.', '/', ':', ';', '<', '=',
	'>', '?', '@', '[', ']', '^', '_', '`', '{', '|', '}', '~', '"'
);

my %b91_dectab;
for (my $i = 0; $i < @b91_enctab; ++$i) {
	$b91_dectab{$b91_enctab[$i]} = $i;
}

use vars qw( $VERSION );
$VERSION = '1.0';

sub import {
	*encode = \&encode_base91;
	*decode = \&decode_base91;
}

sub decode_base91 {
	my @d = split(//,shift(@_));
	my $v = -1;
	my $b = 0;
	my $n = 0;
	my $o;
	my $c;

	for (my $i = 0; $i < @d; ++$i) {
		$c = $b91_dectab{$d[$i]};
		if(!defined($c)){
			next;
		}
		if ($v < 0){
			$v = $c;
		}else{
			$v += $c * 91;
			$b |= ($v << $n);
			$n += ($v & 8191) > 88 ? 13 : 14;
			do {
				$o .= chr($b & 255);
				$b >>= 8;
				$n -= 8;
			} while ($n > 7);
			$v = -1;
		}
	}
	if($v + 1){
		$o .= chr(($b | $v << $n) & 255);
	}
	return $o;
}

sub encode_base91 {
	my @d = split(//,shift(@_));
	my $b = 0;
	my $n = 0;
	my $o;
	my $v;

	for (my $i = 0; $i < @d; ++$i) {
		$b |= ord($d[$i]) << $n;
		$n += 8;
		if($n > 13){
			$v = $b & 8191;
			if ($v > 88){
				$b >>= 13;
				$n -= 13;
			}else{
				$v = $b & 16383;
				$b >>= 14;
				$n -= 14;
			}
			$o .= $b91_enctab[$v % 91] . $b91_enctab[$v / 91];
		}
	}
	if($n){
		$o .= $b91_enctab[$b % 91];
		if ($n > 7 || $b > 90){
			$o .= $b91_enctab[$b / 91];
		}
	}
	return $o;
}

1;
__END__

=head1 NAME

MIME::Base91 - Base91 encoder / decoder

=head1 SYNOPSIS

      use MIME::Base91; 

      $encoded = MIME::Base91::encode($data);
      $decoded = MIME::Base91::decode($encoded);

=head1 DESCRIPTION

Encode data similar way like MIME::Base64 does.

=head1 EXPORT

NOTHING

=head1 AUTHOR

Stefan Gipper <stefanos@cpan.org>, http://www.coder-world.de/

=head1 SEE ALSO

perl(1), MIME::Base64(3pm).

=cut
