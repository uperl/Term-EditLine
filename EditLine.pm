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
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = ();

our $VERSION = '0.05';

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
