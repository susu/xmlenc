package EncParser;


sub parse
{
  my ($fname, $CN) = @_;

  open FH, $fname or die("Cannot open XML file ($fname)! $!");
  my @input = <FH>;
  close FH;

  my $content = join("",@input);

  my $symkey;
  if ($content =~ m/<EncryptedKey Recipient="${CN}">([A-Za-z0-9\+\/\s=]+)<\/EncryptedKey>/sg)
  {
    #print "ENCRYPTED KEY: $1\n";
    $symkey = $1;
  }
  else
  {
    die("Recipient $CN not found!\n");
  }

  my $message;
  if( $content =~ m/<CipherValue>([A-Za-z0-9\+\/\s=]+)<\/CipherValue>/sg )
  {
    #print "ENC MESS: $1\n";
    $message = $1;
  }
  else
  {
    die("Invalid xml format! Missing CipherValue!\n");
  }

  return ($symkey, $message);
}

1;
