package Enc;

use OpenSSL::CliWrapper;
use XMLEnc::EncDoc;
use XMLEnc::EncParser;
use MIME::Base64;

sub encrypt
{
  my ($fname, @recipents) = @_;
  
  open FH, $fname or die("Cannot open input file ($fname)! $!");
  binmode FH;

  my ($message, $data, $n);
  while (($n = read FH, $data, 16) != 0)
  {
    #print "$n bytes read\n";
    $message .= $data;
  }
  close FH;

  my $symmetric_key = CliWrapper::gen_rand_bytes(16);
  my $initial_value = CliWrapper::gen_rand_bytes(16);

  my $xml_builder = EncDoc->new();
  
  foreach( @recipents )
  {
    my $cert = $_;
    print "=== CERT: $_\n";
    if ( not CliWrapper::verify_cert($cert, allow_self_signed => 'yes') )
    {
      die("Certification invalid: $cert");
    }
    else
    {
      my $CN = CliWrapper::get_CN_from_cert( $cert );
      #my $CN = "lehel";
      
      my $encrypted_symkey = $initial_value . CliWrapper::rsa_encrypt($cert, $symmetric_key);

      my $base64_encoded = encode_base64( $encrypted_symkey );
      
      $xml_builder->add_recipent($CN, $base64_encoded );
      #print "recip added: $CN, $base64_encoded\n";
    }
  }

  #print "MESSAGE TO ENCRYPT: $message\n";
  my $aes_method = "aes-128-cfb";
  my $encrypted_message =
    CliWrapper::aes_encrypt(
      $aes_method,
      $message,
      $symmetric_key,
      $initial_value);

  #print "enc.message: $encrypted_message\n";
  my $base64_encoded_message = encode_base64( $encrypted_message );
  #print "base64_encoded_message: $base64_encoded_message\n";
  $xml_builder->set_message( $base64_encoded_message );

  $xml_builder->write_to_file( "$fname.enc" );
}

sub decrypt
{
  my ($fname, $privkey, $CN) = @_;

  my ($base64_encoded_symkey, $base64_encoded_message) = EncParser::parse( $fname, $CN );

  my $encrypted_symkey = decode_base64( $base64_encoded_symkey );
  my $encrypted_message = decode_base64( $base64_encoded_message );
  # first 16 byte of $encrypted_symkey is the initial value!!!
  # extract first 16 byte;
  my @bytes = unpack("C*", $encrypted_symkey);
  my $sizeof = scalar @bytes;

  $sizeof > 16 or die("Invalid size of encrypted symmetric key (".scalar(@bytes).")!");

  #my $initial_value = join('', @bytes[0 .. 15] );
  #my $symkey_only = join('', @bytes[ 16 .. $sizeof-1 ]);
  
  my $initial_value = pack("C*", @bytes[0 .. 15]);
  my $symkey_only   = pack("C*", @bytes[16 .. $sizeof-1]);
  
  my $symkey_decrypted = CliWrapper::rsa_decrypt( $privkey, $symkey_only );

  my $aes_method = "aes-128-cfb";
  my $message =
    CliWrapper::aes_decrypt(
      $aes_method, $encrypted_message, $symkey_decrypted, $initial_value );

  $fname =~ m/(.*)\.enc/;
  my $outfile = "$1";
  open FH, ">$outfile" or die("Cannot open file ($outfile)! $!");
  print FH $message;
  close FH;
}

1;
