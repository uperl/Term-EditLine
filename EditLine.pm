package Term::EditLine;

use strict;
use warnings;

require Exporter;
use AutoLoader;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Term::EditLine ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	CC_ARGHACK
	CC_CURSOR
	CC_EOF
	CC_ERROR
	CC_FATAL
	CC_NEWLINE
	CC_NORM
	CC_REDISPLAY
	CC_REFRESH
	CC_REFRESH_BEEP
	EL_ADDFN
	EL_BIND
	EL_BUILTIN_GETCFN
	EL_CLIENTDATA
	EL_ECHOTC
	EL_EDITMODE
	EL_EDITOR
	EL_GETCFN
	EL_HIST
	EL_PROMPT
	EL_RPROMPT
	EL_SETTC
	EL_SETTY
	EL_SIGNAL
	EL_TELLTC
	EL_TERMINAL
	H_ADD
	H_APPEND
	H_CLEAR
	H_CURR
	H_END
	H_ENTER
	H_FIRST
	H_FUNC
	H_GETSIZE
	H_LAST
	H_LOAD
	H_NEXT
	H_NEXT_EVENT
	H_NEXT_STR
	H_PREV
	H_PREV_EVENT
	H_PREV_STR
	H_SAVE
	H_SET
	H_SETSIZE
	beep
	deletestr
	get
	getc
	gets
	insertstr
	line
	parse
	push
	reset
	resize
	set
	source
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = ();

our $VERSION = '0.01';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    if ($constname eq 'constant') {
      require Carp;
      Carp::croak ("&Term::EditLine::constant not defined");
    }
    my ($error, $val) = constant($constname);
    if ($error) {
      require Carp;
      Carp::croak $error;
    }

    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('Term::EditLine', $VERSION);

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Term::EditLine - Perl interface to the NetBSD editline library

=head1 SYNOPSIS

  use Term::EditLine qw(CC_EOF);

  my $el = Term::EditLine->new('progname');
  $el->set_prompt ( '# ' );

  $el->add_fun ('bye','desc',sub { print "\nbye\n"; return CC_EOF; });

  $el->parse('bind','-e');
  $el->parse('bind','^D','bye');

  while (defined($_ = $el->gets())) {
    $el->history_enter($_);
    print $_;
  }

=head1 DESCRIPTION

Term::EditLine is a compiled module, which provides an object oriented
interface to the NetBSD editline library. Since editline supports readline
and history functions this module is almost a full replacement for the
Term::ReadLine module even though it is much smaller than any existing
Term::ReadLine interface.

=head2 Functions

=over 4

=item new ( PROGNAME, [ IN, OUT, ERR ] )

Creates a new Term::EditLine object. Argument is the name of
the application. Optionally can be followed by three arguments
for the input, output, and error filehandles. These arguments
should be globs. See also el_init(3).

=item gets

Read a line from the tty. If successful returns the line read,
or undef if no characters where read or if an error occured.

=item set_prompt ( PROMPT )

Define the prompt. Argument may either be a perl sub, which has
to return a string that contains the prompt, or a string.

=item set_rprompt ( PROMPT )

Define the right side prompt. Argument may either be a perl sub,
which has to return a string that contains the prompt, or a string.

=item set_editor ( MODE )

Set editing mode to mode, which must be one of "emacs" or "vi".

=item add_fun ( NAME, HELP, FUN )

See el_set(3). This functions performs an
el_set( editline, EL_ADDFN, NAME, HELP, FUN ) call. FUN is to be a
reference to a perl subroutine.

=item history_set_size ( SIZE )

Set size of history to SIZE elements.

=item history_get_size

Return the number of events currently in history.

=item history_clear

Clear the history.

=item history_get_first

Return the first element in the history.

=item history_get_last

Return the last element in the history.

=item history_get_prev

Return the previous element in the history.

=item history_get_next

Return the next element in the history.

=item history_get_curr

Return the current element in the history.

=item history_add ( STR )

Append STR to the current element of the history, or create
an element with.

=item history_append ( STR )

Append STR to the last new element of the history.

=item history_enter ( STR )

Add STR as a new element to the history, and, if necessary,
removing the oldest entry to keep the list to the created
size.

=item history_get_prev_str ( STR )

Return the closest previous event that starts with STR.

=item history_get_next_str ( STR )

Return the closest next event that starts with STR.

=item history_load ( FILENAME )

Load the history list stored in FILENAME.

=item history_save ( FILENAME )

Save the history list to FILENAME.

=head2 Additional functions

The following functions are simply perl wrappers of the C functions
documented in editline(3):

=over 4

=item reset

=item getc

=item push

=item resize

=item line

=item insertstr

=item deletestr

=head1 EXPORT

None by default.

=head2 Exportable constants

  CC_ARGHACK
  CC_CURSOR
  CC_EOF
  CC_ERROR
  CC_FATAL
  CC_NEWLINE
  CC_NORM
  CC_REDISPLAY
  CC_REFRESH
  CC_REFRESH_BEEP

=head1 SEE ALSO

editline(3), editrc(5)

=head1 AUTHOR

Ulrich Burgbacher, E<lt>ulrich@burgbacher.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Ulrich Burgbacher

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
