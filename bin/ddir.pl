#! /usr/bin/perl
#
#   ddir - Display hierarchical directory tree
#
#   Copyright
#
#       Copyright (C) 1995-2025 Jari Aalto
#       Copyright (C) 1994 Brian Blackmore
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   Documentation
#
#       To read manual, start this program with option: --help
#
#       Origianally by Brian Blackmore. Modernized by Jari Aalto

# ********************************************************************
#
#   Standard perl modules
#
# ********************************************************************

use strict;

use English qw(-no_match_vars);
use Getopt::Long;
use File::Basename;
#use File::Find;

use autouse 'Pod::Text' => qw(pod2text);
use autouse 'Pod::Html' => qw(pod2html);
use Pod::Man;

# ********************************************************************
#
#   GLOBALS
#
# ********************************************************************

use vars qw ($VERSION $DEFAULT_PATH_EXCLUDE);

# This is for use of Makefile.PL and ExtUtils::MakeMaker
#
# The following variable is updated by custom Emacs setup whenever
# this file is saved.

my $VERSION = '2025.0204.0954';
my $CONTACT = "Jari Aalto";
my $LICENSE = "GPL-2.0-or-later";        # See SPDX License List
my $URL     = 'https://github.com/jaalto/project--perl-ddir';

my $DEFAULT_PATH_EXCLUDE =              # Matches *only path component
    '(\.(bzr|svn|git|darcs|arch|mtn|hg)|CVS|RCS)$'
    ;

# ********************************************************************
#
#   DESCRIPTION
#
#       Set global variables for the program
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ********************************************************************

sub Initialize ()
{
    use vars qw
    (
        $LIB
        $PROGNAME
    );

    $LIB        = basename $PROGRAM_NAME;
    $PROGNAME   = $LIB;

    $OUTPUT_AUTOFLUSH = 1;
}

# ********************************************************************
#
#   DESCRIPTION
#
#       Help function and embedded POD documentation
#
#   INPUT PARAMETERS
#
#       none
#
#   RETURN VALUES
#
#       none
#
# ********************************************************************

=pod

=head1 NAME

ddir - display hierarchical directory tree

=head1 SYNOPSIS

  ddir [options] [DIR]

=head1 DESCRIPTION

Displays an indented directory tree using ASCII graphical characters to
represent the hierarchical structure. Directories to include or exclude
can be specified with command-line options.

ddir(1) is a Perl implementation of the tree(1) program. The extra
"d" in its name differentiates it from the existing dir(1) program.

=over 4

=item B<-d, --dir>

Display only directories.

=item B<-i, --include REGEXP>

Include files matching the specified regular
expression. The match is performed against the entire
path. This option can be used multiple times.

If this option is not supplied, all files are included
by default. Matches can be further filtered using the
B<--exclude> option.

=item B<-n, --no-exclude-vcs>

Do not exclude version-controlled directories.

=item B<-v, --verbose LEVEL>

Display informational messages. Increase the numeric
LEVEL for more verbosity.

=item B<-x, --exclude REGEXP>

Ignore files matching the specified regular expression.
The match is performed against the entire path. This
option can be used multiple times.

This option is applied after possible B<--include> matches.

B<--include> matches.

=item B<-X, --exclude-vcs>

Enabled by default. Excludes version control
directories. See B<--help-exclude> for details.

Use B<--no-exclude-vcs> to include all files in the
listing.

=item B<-h, --help>

Display this help page.

=item B<--help-exclude>

Display the default exclusion values used when
B<--exclude-vcs> is enabled.

=item B<--help-html>

Display help in HTML format.

=item B<--help-man>

Display help in manual page C<man(1)> format.

=item B<-V, --version>

Display version and contact information.

=back

=head1 EXAMPLES

Display the directory tree while excluding version control
directories. Display only directories:

    ddir --dir .

    .
    +--doc/
    |  +--manual/
    +--bin/

=head1 TROUBLESHOOTING

None.

=head1 ENVIRONMENT

None.

=head1 FILES

None.

=head1 EXIT STATUS

Not defined.

=head1 DEPENDENCIES

Uses standard Perl modules.

=head1 BUGS AND LIMITATIONS

None.

=head1 SEE ALSO

dir(1)
tree(1)
wcd(1)

=head1 AVAILABILITY

Homepage is at https://github.com/jaalto/project--perl-ddir

=head1 AUTHOR

Jari Aalto

=head1 LICENSE AND COPYRIGHT

Copyright (C) 1995-2025 Jari Aalto.
Copyright (C) 1994 Brian Blackmore.

This program and its documentation is free software; you can
redistribute and/or modify program under the terms of GNU General
Public license either version 2 of the License, or (at your option)
any later version.

See https://spdx.org/licenses/

=cut

sub Help(;$$)
{
    my $id   = "$LIB.Help";
    my $type = shift;  # optional arg, type
    my $msg  = shift;  # optional arg, why are we here...

    if ($type eq -html)
    {
        pod2html $PROGRAM_NAME;
    }
    elsif ($type eq -man)
    {
        my %options;
        $options{center} = "User commands";

        my $parser = Pod::Man->new(%options);
        $parser->parse_from_file ($PROGRAM_NAME);
    }
    else
    {
        if ($PERL_VERSION =~ /5\.10/)
        {
            # Bug in 5.10. Cant use string ("") as a
            # symbol ref while "strict refs" in use at
            # /usr/share/perl/5.10/Pod/Text.pm line 249.

            system "pod2text $PROGRAM_NAME";
        }
        else
        {
            pod2text $PROGRAM_NAME;
        }
    }

    defined $msg  and  print $msg;
    exit 0;
}

# ********************************************************************
#
#   DESCRIPTION
#
#       Return current year YYYY
#
#   INPUT PARAMETERS
#
#       None
#
#   RETURN VALUES
#
#       number      YYYY
#
# ********************************************************************

sub HelpExclude()
{
    my $id = "$LIB.HelpExclude";

    print "Default path exclude regexp: '$DEFAULT_PATH_EXCLUDE'\n";
}

# ********************************************************************
#
#   DESCRIPTION
#
#       Read command line arguments and their parameters.
#
#   INPUT PARAMETERS
#
#       None
#
#   RETURN VALUES
#
#       Globally set options.
#
# ********************************************************************

sub HandleCommandLineArgs()
{
    my $id = "$LIB.HandleCommandLineArgs";

    use vars qw
    (
        $test
        $verb
        $debug
        @OPT_FILE_REGEXP_EXCLUDE
        $OPT_FILE
    );

    Getopt::Long::config(qw
    (
        no_ignore_case
        no_ignore_case_always
    ));

    my ($help, $helpMan, $helpHtml, $version); # local variables to function
    my ($helpExclude, $optDir, $optVcs, $optVcsNot);

    $debug = -1;
    $OPT_FILE = 1;
    $optVcs = 1;            # On by default

    GetOptions              # Getopt::Long
    (
          "dir"                 => \$optDir
        , "help-exclude"        => \$helpExclude
        , "help-html"           => \$helpHtml
        , "help-man"            => \$helpMan
        , "h|help"              => \$help
        , "v|verbose:i"         => \$verb
        , "V|version"           => \$version
        , "n|no-exclude-vcs"    => \$optVcsNot
        , "x|exclude=s"         => \@OPT_FILE_REGEXP_EXCLUDE
        , "X|exclude-vcs"       => \$optVcs
    );

    $version            and  die "$VERSION $CONTACT $LICENSE $URL\n";
    $helpExclude        and  HelpExclude();
    $help               and  Help();
    $helpMan            and  Help(-man);
    $helpHtml           and  Help(-html);
    $version            and  Version();

    $debug = 1          if $debug == 0;
    $debug = 0          if $debug < 0;
    $optVcsNot          and $optVcs = 1;

    $OPT_FILE = 0       if $optDir;

    push @OPT_FILE_REGEXP_EXCLUDE, $DEFAULT_PATH_EXCLUDE if $optVcs;
}

# ********************************************************************
#
#   DESCRIPTION
#
#       Check if FILE matches exclude regexps.
#
#   INPUT PARAMETERS
#
#       $       Filename
#
#   RETURN VALUES
#
#       true    File in exclude list
#       false   File NOT in exclude list
#
# ********************************************************************

sub IsExclude($)
{
    my $id = "$LIB.IsExclude";
    local $ARG = shift;

    @OPT_FILE_REGEXP_EXCLUDE  or  return 0;

    for my $re (@OPT_FILE_REGEXP_EXCLUDE)
    {

        if (/$re/)
        {
            $verb > 2  and  print "$id: '$re' matches: $ARG\n";
            return 1
        }
    }

    return 0;
}

# ********************************************************************
#
#   DESCRIPTION
#
#       Resolve a pathname into its shortest version Removing any
#       references to the directory ".", any references to // , any
#       references to directory/.. and any final /
#
#   INPUT PARAMETERS
#
#       $file
#       $directory
#
#   RETURN VALUES
#
#       $file
#
# ********************************************************************

sub Resolve($$)
{
    my $id = "$LIB.Resolve";
    my ($file, $directory) = @ARG;

    $ARG = $file;        # DO NOT 'local $ARG'. See caller code

    m,^/, || s,^,$directory/,;

    while (s,/\.?/,/,  or  s,/[^/]+/\.\./,/,  or  s,/\.?$,,)
    {
        # Run the substitutions
    }

    $ARG = "/"  unless $ARG;

    $ARG;
}

# ********************************************************************
#
#   DESCRIPTION
#
#       Scan a directory and print out the files in each directory in
#       a pretty format. Note: recursive.
#
#   INPUT PARAMETERS
#
#       $
#       $
#
#   RETURN VALUES
#
#       $
#
# ********************************************************************

sub Tree($$);   # Forward declaration for recursive use.

sub Tree($$)
{
    my $id = "$LIB.Tree";
    my ($dir, $level) = @ARG;

    local $ERRNO = "";

    opendir my $DIR, $dir;

    if ($ERRNO)
    {
        warn "Could not open directory $dir '$ERRNO'\n";
        return;
    }

    my @files = readdir $DIR;

    close $DIR;

    # sort out non-dirs to display first, then directories.

    my (@d, @f);
    local $ARG = "";

    for (@files)
    {
        -d "$dir/$ARG"  and  push(@d, $ARG), next;
        push @f, $ARG;
    }

    @files = (sort(@f), sort @d);               # Rearrange nicely

    while (my $name = shift @files)
    {
        next if $name =~ /^\.\.?$/; # Skip directories .  and  ..

        $ARG = Resolve $name, $dir;

        next if IsExclude $ARG;

        if ($OPT_FILE  and  -f)
        {
            s,.*/,,;

            print "$level$ARG\n";
        }
        elsif (-d)
        {
            my $newname = $ARG;

            if (-l $newname)
            {
                 # Do not follow symlinks

                 $newname = readlink $ARG;
                 print "$level+--$name -> $newname\n";
            }
            elsif (-r _ and -x _)
            {
                # We must be able to enter a directory in order to tree it

                print "$level+--$name/\n";

                if (@files)
                {
                    Tree $newname, "$level|  ";
                }
                else
                {
                    Tree $newname, "$level   ";
                }
            }
            else
            {
                print "$level\--$name/ (unreadable)\n";
            }
        }
    }
}

# ********************************************************************
#
#   DESCRIPTION
#
#       Main progra.
#
#   INPUT PARAMETERS
#
#       None
#
#   RETURN VALUES
#
#       None
#
# ********************************************************************

sub Main()
{
    Initialize();
    HandleCommandLineArgs();

    my $dir = $ARGV[0] || ".";

    print "$dir\n";
    Tree $dir, "";
}

Main();

# End of file
