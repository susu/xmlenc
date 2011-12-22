##!/usr/bin/perl

package CliWrapper;

use IPC::Open2;

sub openssl_cmd
{
  my ($cmd) = shift;
  my (%args) = @_;

  if (not exists $args{way})
  {
    die("way parameter not defined!\n");
  }
  elsif ($args{way} eq "in")
  {
    exists $args{in} or die("Missing 'in' parameter!");
    #print "Executing: $cmd\n";
    return openssl_input_cmd($cmd, $args{in});
  }
  elsif ($args{way} eq "out")
  {
    #print "Executing: $cmd\n";
    return openssl_output_cmd($cmd);
  }
  elsif ($args{way} eq "inout")
  {
    exists $args{in} or die("Missing 'in' parameter!");
    #print "Executing: $cmd\n";
    return openssl_inout_cmd($cmd, $args{in});
  }
  else
  {
    die("Wrong 'way' parameter!");
  } 
}


sub openssl_inout_cmd
{
  my ($cmd, $in) = @_;
  #print "openssl_inout_cmd entered.\n";
  
  open2(*PROC_OUT, *PROC_IN, $cmd);
  print PROC_IN "$in";
  close(PROC_IN);
  #print "send to input: $in\n";

  binmode PROC_OUT;
  
  my ($buf, $data, $n);
  while (($n = read PROC_OUT, $data, 16) != 0)
  {
    #print "$n bytes read\n";
    $buf .= $data;
  }

  close(PROC_OUT);
  return $buf;
}

sub openssl_output_cmd
{
  my ($cmd) = @_;
  open PROC_OUT, "$cmd |";
  
  binmode PROC_OUT;
  
  my ($buf, $data, $n);
  while (($n = read PROC_OUT, $data, 16) != 0)
  {
    #print "$n bytes read\n";
    $buf .= $data;
  }

  close(PROC_OUT);
  return $buf;
}

sub bytes_to_hex
{
  my ($bytes) = @_;

  my @arr = unpack("C*", $bytes);
  
  my $retval = "";
  foreach ( @arr )
  {
    $retval .= sprintf("%02x", $_);
  }
  return $retval;
}

sub aes_encrypt
{
  my ($method, $plaintext, $key, $iv) = @_;

  $key = bytes_to_hex $key;
  $iv  = bytes_to_hex $iv;
  
  my $CMD = "openssl enc -$method -K $key -iv $iv";
  #print "AES encrypt: $CMD\n";
  #print "plaintext: $plaintext\n";
  return openssl_cmd($CMD,
                     in => $plaintext,
                     way=> "inout");
}

sub aes_decrypt
{
  my ($method, $secret, $key, $iv) = @_;
  
  $key = bytes_to_hex $key;
  $iv  = bytes_to_hex $iv;
  
  my $CMD = "openssl enc -d -$method -K $key -iv $iv";
  
  return openssl_cmd($CMD,
                     in => $secret,
                     way=> "inout");
}


sub rsa_encrypt
{
  my ($cert_filename, $plaintext) = @_;
  die("Certification not exists! $cert_filename") unless( -e $cert_filename );

  my $CMD = "openssl rsautl -encrypt -inkey $cert_filename  -certin";
  
  return openssl_cmd($CMD, in => $plaintext, way => "inout" );
}

sub rsa_decrypt
{
  my ($privkey, $secret) = @_;
  die("Privkey not exists! $privkey") unless( -e $privkey );

  my $CMD = "openssl rsautl -decrypt -inkey $privkey";

  return openssl_cmd($CMD, in => $secret, way => 'inout');
}

sub gen_rand_bytes
{
  my ($keysize) = @_;
  return openssl_cmd( "openssl rand $keysize", way => "out");
}


sub get_CN_from_cert
{
  my ($cert_filename) = shift;

  my $cmd = "openssl x509 -in $cert_filename -noout -text";
  open PROC, "$cmd |" or die("Cannot execute $!");

  while(<PROC>)
  {
    if (/Subject:.*CN=([A-Za-z0-9\.]+)/)
    {
      return $1;
    }
  }
  close PROC;

  die("Invalid certification file: $cert_filename!");
}

sub verify_cert
{
  my ($cert_filename) = shift;
  my (%args) = @_;
  
  my $cmd = "openssl verify $cert_filename";
  open PROC, "$cmd |" or die("Cannot execute: $!");

  my $selfsigned = 0;
  while(<PROC>)
  {
    #print "LINE: $_\n";
    if (/${filename}: OK/)
    {
      return 1;
    }
    if (/error.*certificate has expired/)
    {
      return 0;
    }
    if ($args{allow_self_signed} eq 'yes')
    {
      if (/self signed certificate/)
      {
        $selfsigned = 1;
      }
    }
  }
  close PROC;

  if ($selfsigned) {
    return 1;
  }

  if (defined $args{allow_self_signed} and 
      not $args{allow_self_signed} =~ m/(yes|no)/)
  {
    die("Wrong 'allow_self_signed' parameter!");
  }
  return 0;
}

#### TESTING THE MODUE ####

#sub to_hex
#{
#  my ($string) = @_;
#  #return sprintf("%x",$string);
#  my @arr = unpack("C*", $string);
#  my $retval = "\n";
#  my $i=1;
#  foreach(@arr)
#  {
#     $retval .= sprintf ("%02x ", $_ );
#     if ($i % 8 == 0) 
#     {
#       $retval .= "\n";
#     }
#     $i++;
#  }
#  return $retval;
#}
#
#my $key = "1234567890123456";
#my $iv  = "6543210987654321";
#
#my $plaintext = "Ezt akarom titkositani hehhhhhhhhhhhh!";
#
#print "TEST openssl:\n".
#      "  key: " . to_hex($key) . "\n" .
#      "  iv:  " . to_hex($iv) . "\n";
#
#my $secret = aes_encrypt("aes-128-cfb", $plaintext, $key, $iv);
#
#print "plaintext: $plaintext\nin hex:" . to_hex($plaintext) . "\n";
#
#print "encrypted in hex: " . to_hex($secret) . "\n";
#
#my $decr = decrypt("aes-128-cfb", $secret, $key, $iv);
#
#print "decrypted: $decr\nin hex: " . to_hex($decr) . "\n";
#
#if ( $decr eq $plaintext )
#{
#  print "RESULT: OK!\n";
#}
#else
#{
#  print "RESULT: FAILED!!!\n";
#}

1;
