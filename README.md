# Term::EditLine ![static](https://github.com/uperl/Term-EditLine/workflows/static/badge.svg) ![linux](https://github.com/uperl/Term-EditLine/workflows/linux/badge.svg)

Perl interface to the NetBSD editline library

# SYNOPSIS

```perl
 use Term::EditLine qw(CC_EOF);

 my $el = Term::EditLine->new('progname');
 $el->set_prompt ('# ');

 $el->add_fun ('bye','desc',sub { print "\nbye\n"; return CC_EOF; });

 $el->parse('bind','-e');
 $el->parse('bind','^D','bye');

 while (defined(my $line = $el->gets())) {
   $el->history_enter($_);
   print $_;
 }
```

# DESCRIPTION

Term::EditLine is a compiled module, which provides an object oriented
interface to the NetBSD editline library. Since editline supports readline
and history functions this module is almost a full replacement for the
Term::ReadLine module even though it is much smaller than any existing
Term::ReadLine interface.

## Functions

- new ( PROGNAME, \[ IN, OUT, ERR \] )

    Creates a new Term::EditLine object. Argument is the name of
    the application. Optionally can be followed by three arguments
    for the input, output, and error filehandles. These arguments
    should be globs. See also el\_init(3).

- gets

    Read a line from the tty. If successful returns the line read,
    or undef if no characters where read or if an error occured.

- set\_prompt ( PROMPT )

    Define the prompt. Argument may either be a perl sub, which has
    to return a string that contains the prompt, or a string.

- set\_rprompt ( PROMPT )

    Define the right side prompt. Argument may either be a perl sub,
    which has to return a string that contains the prompt, or a string.

- set\_editor ( MODE )

    Set editing mode to mode, which must be one of "emacs" or "vi".

- add\_fun ( NAME, HELP, FUN )

    See el\_set(3). This functions performs an
    el\_set( editline, EL\_ADDFN, NAME, HELP, FUN ) call. FUN is to be a
    reference to a perl subroutine.

- line

    Returns three items (in this order): the current string buffer of the
    Term::EditLine structure, the index of the cursor, and the index of the
    last character.

- set\_getc\_fun ( SUBREF )

    Define the character reading function as SUBREF. This function is to
    return one single character. It is called internally by gets() and getc().
    It is useful to define a custom getc function, if you want to write an
    interactive program with line editing function that has to process events
    when no input is available. A simple tcp chatclient example:

    ```perl
     use Term::EditLine;
     use IO::Socket;
     use strict;

     my ($sock,$el,$rin,$buf);

     $sock = IO::Socket::INET->new("$ARGV[0]:$ARGV[1]") or die "...";

     $rin = '';
     vec($rin,fileno($sock),1) = 1;
     vec($rin,fileno(STDIN),1) = 1;

     $el = Term::EditLine->new('example');

     $el->set_prompt('$ ');
     $el->set_getc_fun(\&get_c);
     $el->bind('-e');

     while (defined($_ = $el->gets)) {
       chomp;
       syswrite($sock,"$_\n",length($_)+1);
     }

     sub get_c {
       my ($tmp,$i,$c);
       while (1) {
         my $rout = $rin;
         if (select ($rout,undef,undef,0.1)) {
           if (vec($rout,fileno($sock),1)) {
             if(sysread ($sock,$tmp,1024)) {
               $tmp = $buf . $tmp;
             }
             while (($i = index($tmp,"\n")) != -1) {
               $_ = substr ($tmp,0,$i);
               chomp ($_);
               print "\r\e[0J";                 # ugly
               print "$_\n". $el->get_prompt(); # hack!
               $tmp = substr($tmp,$i+1<=length($tmp)?$i+1:length($i+1));
             }
             $buf = $tmp;
           }
           if (vec($rout,fileno(STDIN),1)) {
             sysread(STDIN,$c,1);
             return $c;
           }
         }
       }
     }
    ```

- restore\_getc\_fun

    Restore the editline builtin getc function.

- history\_set\_size ( SIZE )

    Set size of history to SIZE elements.

- history\_get\_size

    Return the number of events currently in history.

- history\_clear

    Clear the history.

- history\_get\_first

    Return the first element in the history.

- history\_get\_last

    Return the last element in the history.

- history\_get\_prev

    Return the previous element in the history.

- history\_get\_next

    Return the next element in the history.

- history\_get\_curr

    Return the current element in the history.

- history\_add ( STR )

    Append STR to the current element of the history, or create
    an element with.

- history\_append ( STR )

    Append STR to the last new element of the history.

- history\_enter ( STR )

    Add STR as a new element to the history, and, if necessary,
    removing the oldest entry to keep the list to the created
    size.

- history\_get\_prev\_str ( STR )

    Return the closest previous event that starts with STR.

- history\_get\_next\_str ( STR )

    Return the closest next event that starts with STR.

- history\_load ( FILENAME )

    Load the history list stored in FILENAME.

- history\_save ( FILENAME )

    Save the history list to FILENAME.

## Additional functions

The following functions are simply perl wrappers of the C functions
documented in editline(3):

- reset
- getc
- push
- resize
- insertstr
- deletestr

# EXPORT

None by default.

## Exportable constants

```
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
```

# CAVEATS

The non-blocking interface of libedit sucks. Only ugly hacks make it possible
to redisplay the prompt when data is displayed from other fds than the libedit
output fd. Future versions of Term::EditLine will probably contain a modified
version of libedit that provides redisplay functions.

# SUPPORT

To report bugs, please use the GitHub bugtracker:

[https://github.com/uperl/Term-EditLine/issues](https://github.com/uperl/Term-EditLine/issues)

To submit patches, please create a pull request on GitHub:

[https://github.com/uperl/Term-EditLine/pulls](https://github.com/uperl/Term-EditLine/pulls)

# SEE ALSO

- [Alien::Editline](https://metacpan.org/pod/Alien::Editline)
- editline(3)
- editrc(5)

# AUTHORS

- Ulrich Burgbacher <ulrich@burgbacher.net>
- Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2003-2026 by Ulrich Burgbacher.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
