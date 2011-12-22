#!/usr/bin/perl


use Getopt::Long;
use Term::ANSIColor qw(:constants);
local $Term::ANSIColor::AUTORESET = 1;

use Enc;

sub error_print
{
  print RED "$_[0]\n";
}

sub usage
{
  return "Usage:\n".
         "  -e, --encode                     Encrypt message\n".
         "  -d, --decode                     Decrypt message\n".
#         "  -o, --output                     output filename\n".
         "Mandatory parameters in case of encrypt:\n".
         "  -c, --certificate-recipent       Recipent's cert\n".
         "  -i, --input                      input file to encrypt\n".
         "Mandatory parameters in case of decrypt:\n".
         "  -i, --input                      input file to decrypt\n".
         "  -p, --privkey                    private key for deciphering\n".
         "  --common-name=CN                 My Common Name, to identify myself\n".
         "\n";
}

my %opts;

my $encode;
my $decode;
my $recipent;
my $fname;
my $privkey;
my $cn;

GetOptions( "encode" => \$encode,
            "decode" => \$decode,
            "certificate-recipent=s" => \$recipent,
            "input=s" => \$fname,
            "privkey=s" => \$privkey,
            "common-name=s" => \$cn );


if ($encode and $decode)
{
  error_print "Use only one operation at a time!";
  print usage();
}
elsif ($encode)
{
  print "Encryption...\n";
  $fname or die("No inputfile given!");
  $recipent or die("No recipent given!");
  Enc::encrypt( $fname, $recipent );
}
elsif ($decode)
{
  print "Decryption...\n";
  $fname or die("No inputfile given!");
  $privkey or die("No private keyfile given!");
  $cn or die("No Common Name given!");
  Enc::decrypt( $fname, $privkey, $cn );
}
else
{
  error_print "No operation given!";
  print usage();
}


