#!/usr/bin/env perl

use strict;
use warnings;

use Term::EditLine qw(CC_EOF);

use v5.14;

my $el = Term::EditLine->new('progname');
$el->set_prompt ('# ');

$el->add_fun ('bye','desc',sub { say "\nbye"; return CC_EOF; });

$el->parse('bind','-e');
$el->parse('bind','^D','bye');

while (defined($_ = $el->gets())) {
  $el->history_enter($_);
  say $_;
}
