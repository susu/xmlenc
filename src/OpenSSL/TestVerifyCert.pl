#!/usr/bin/perl

use CliWrapper;

sub verif
{
  my ($fname) = @_;
  if ( CliWrapper::verify_cert($fname, allow_self_signed=>"yes") )
  {
    print "$fname is ok.\n";
  }
  else
  {
    print "$fname is WRONGGG!\n";
  }

}


verif("test_certs/mail.google.com");
verif("test_certs/self_signed.pem");
verif("test_certs/expired.pem");


print "1 " . CliWrapper::get_CN_from_cert("test_certs/mail.google.com"). "\n";
print "2 " . CliWrapper::get_CN_from_cert("test_certs/self_signed.pem"). "\n";
print "3 " . CliWrapper::get_CN_from_cert("test_certs/expired.pem"). "\n";

