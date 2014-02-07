use ExtUtils::MakeMaker 6.48;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.



WriteMakefile(
    'NAME'		=> 'Term::EditLine',
    'VERSION_FROM'	=> 'EditLine.pm', # finds $VERSION
    'PREREQ_PM'		=> {
         'Test::More' => 0.96,
	},
    'CONFIGURE_REQUIRES' => {
      "ExtUtils::MakeMaker" => "6.48"
    },
    'MIN_PERL_VERSION'  => '5.006000',
    'ABSTRACT_FROM'     => 'EditLine.pod',
    'AUTHOR'            => 'Ulrich Burgbacher <ulrich@burgbacher.net>',
    'LIBS'		=> ['-ledit'
			 .($^O =~ /openbsd/i && ' -lcurses')], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # 'OBJECT'		=> '$(O_FILES)', # link all the C files too
);
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.
  my @names = (qw(CC_ARGHACK CC_CURSOR CC_EOF CC_ERROR CC_FATAL CC_NEWLINE
		 CC_NORM CC_REDISPLAY CC_REFRESH CC_REFRESH_BEEP EL_ADDFN
		 EL_BIND EL_BUILTIN_GETCFN EL_CLIENTDATA EL_ECHOTC EL_EDITMODE
		 EL_EDITOR EL_GETCFN EL_HIST EL_PROMPT EL_RPROMPT EL_SETTC
		 EL_SETTY EL_SIGNAL EL_TELLTC EL_TERMINAL H_ADD H_APPEND
		 H_CLEAR H_CURR H_END H_ENTER H_FIRST H_FUNC H_GETSIZE H_LAST
		 H_LOAD H_NEXT H_NEXT_EVENT H_NEXT_STR H_PREV H_PREV_EVENT
		 H_PREV_STR H_SAVE H_SET H_SETSIZE));
  ExtUtils::Constant::WriteConstants(
                                     NAME         => 'Term::EditLine',
                                     NAMES        => \@names,
                                     DEFAULT_TYPE => 'IV',
                                     C_FILE       => 'const-c.inc',
                                     XS_FILE      => 'const-xs.inc',
                                  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}
