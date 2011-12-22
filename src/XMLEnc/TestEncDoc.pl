#!/usr/bin/perl

use EncDoc;



my $b = EncDoc->new();


$b->add_recipent("elso_csapat", "titkossag");
$b->add_recipent("masodik_csapat", "titkossag2");
$b->add_recipent("harmadik_csapat", "titkossag3");

$b->print_recipents();

$b->set_message("hellothere");

$b->write_to_file("output.xml");

