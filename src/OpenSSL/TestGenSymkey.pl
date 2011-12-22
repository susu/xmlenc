#!/usr/bin/perl

use CliWrapper;


sub to_hex
{
  my ($string) = @_;
  #return sprintf("%x",$string);
  my @arr = unpack("C*", $string);
  my $retval = "\n";
  my $i=1;
  foreach(@arr)
  {
     $retval .= sprintf ("%02x ", $_ );
     if ($i % 8 == 0) 
     {
       $retval .= "\n";
     }
     $i++;
  }
  return $retval;
}

my $key = CliWrapper::gen_rand_bytes(16);

print to_hex($key) . "\n";

