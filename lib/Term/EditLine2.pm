package Term::EditLine2;

use strict;
use warnings;
use base qw( Term::EditLine );
use Term::EditLine qw( :all );

our @EXPORT = @Term::EditLine::EXPORT;
our @EXPORT_OK = @Term::EditLine::EXPORT_OK;
our %EXPORT_TAGS = @Term::EditLine::EXPORT_TAGS;

our $VERSION = '0.06';

=head1 NAME

Term::EditLine2

=head1 SYNOPSIS

 use Term::EditLine; # Term::EditLine2 is deprecated

=head1 DESCRIPTION

This was originall a fork of L<Term::EditLine>, which has since
been reintegrated into the original L<Term::EditLine>.  This module
remains as a compatability interface.  I believe the users of
this fork to be relatively small (if any) so I will be deprecating
this one and removing it from CPAN, but no sooner than
September 12, 2015.  If at all possible please migrate to the original
module.  If this will cause you significant harm, please let me know
via the project bug tracker, depending on the circumstances I can
extend the life of this compatability layer.

=head1 SEE ALSO

L<Term::EditLine>

=head1 SUPPORT

To report bugs, please use the GitHub bugtracker:

L<https://github.com/plicease/Term-EditLine/issues>

To submit patches, please create a pull request on GitHub:

L<https://github.com/plicease/Term-EditLine/pulls>

=head1 AUTHOR

Original Author:

Ulrich Burgbacher, E<lt>ulrich@burgbacher.netE<gt>

Current Maintainer:

Graham Ollis E<lt>plicease@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Ulrich Burgbacher

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
