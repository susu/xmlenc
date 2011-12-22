#!/usr/bin/perl

sub to_hex
{
  my ($string) = @_;
  #return sprintf("%x",$string);
  my @arr = unpack("C*", $string);
  my $retval = "";
  foreach(@arr)
  {
     $retval .= sprintf ("%02x,", $_ );
  }
  return $retval;
}

#use Crypt::OpenSSL::AES;
use Crypt::Rijndael;
use Crypt::OpenSSL::Random;

my $seed = time;
Crypt::OpenSSL::Random::random_seed( $seed );


Crypt::OpenSSL::Random::random_status() or
    die "Unable to sufficiently seed the random number generator".

print "AES stuff\n";

#my $key = Crypt::OpenSSL::Random::random_bytes(16);
my $key = "6543210987654321";
my $iv = "6543210987654321";

my $cipher = Crypt::Rijndael->new( $key, Crypt::Rijndael::MODE_CFB() );


$cipher->set_iv( $iv );

my $plaintext = "1234567890123456";

my $secret = $cipher->encrypt( $plaintext );

print "plaintext:\n".
      to_hex($plaintext) . "\n";

print "secret:\n".
      to_hex($secret) . "\n";

print "decrypted:\n" .
      to_hex( $cipher->decrypt( $secret ) ) . "\n";

