package EncDoc;


sub new
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  
  $self->{recipents} = ();
  $self->{encrypted_message} = undef;

  bless($self,$class);
  return $self;
}

sub add_recipent
{
  my($self, $name, $encrypted_key) = @_;

  $self->{recipents}->{ $name } = $encrypted_key;
}

sub set_message
{
  my ($self, $mess) = @_;
  $self->{encrypted_message} = $mess;
}

sub print_recipents
{
  my ($self) = @_;

  foreach( keys %{ $self->{recipents} } )
  {
    print "name: $_ => $self->{recipents}->{ $_ }\n";
  }
}

sub write_to_file
{
  my ($self, $filename) = @_;

  if (not defined $filename)
  {
    die("filename missing!\n");
  }
  if (not defined $self->{encrypted_message})
  {
    die("missing message!\n");
  }

  open OUTF, ">$filename" or die("Cannot open file! ($!)");
  print OUTF
  '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'. "\n" .
  '<EncryptedData type="http://www.w3.org/2001/04/xmlenc#Element">' . "\n" .
  "  <KeyInfo>\n";

  foreach( keys %{ $self->{recipents} } )
  {
    print OUTF "    <EncryptedKey Recipient=\"$_\">".
          "$self->{recipents}->{ $_ }".
          "</EncryptedKey>\n";
  }

  print OUTF "  </KeyInfo>\n".
  "  <CipherData>\n".
  "    <CipherValue>$self->{encrypted_message}</CipherValue>\n".
  "  </CipherData>\n</EncryptedData>";

  print OUTF "</KeyInfo>\n";
  close(OUTF);
}

1;
