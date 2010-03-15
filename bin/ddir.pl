#!/usr/bin/perl
'di';
'ig00';

# ddir.pl -- Display DOS style hierarchical directory tree
#
#       Copyright (C) 1995-2010 Jari Aalto
#       Copyright (C) 1994 Brian Blackmore
#
#       This program is free software; you can redistribute it and/or
#       modify it under the terms of the GNU General Public License as
#       published by the Free Software Foundation; either version 2 of
#       the License, or (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful, but
#       WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#       General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#       Visit <http://www.gnu.org/copyleft/gpl.html> for more information
#
#   Description
#
#       Origianally by Brian Blackmore. Modernized by Jari Aalto

# ****************************************************************************
#
#   Standard perl modules
#
# ****************************************************************************

use English qw( -no_match_vars );

# ****************************************************************************
#
#   GLOBALS
#
# ****************************************************************************

use vars qw ( $VERSION );

#   This is for use of Makefile.PL and ExtUtils::MakeMaker
#
#   The following variable is updated by custom Emacs setup whenever
#   this file is saved.

my $VERSION = '2010.0315.0958';

# ****************************************************************************
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
# ****************************************************************************

sub Initialize ()
{
    use vars qw
    (
        $LIB
        $PROGNAME
        $CONTACT
	$LICENSE
        $URL
    );

    $LICENSE	= "GPL-2+";
    $LIB        = basename $PROGRAM_NAME;
    $PROGNAME   = $LIB;

    $CONTACT     = "Jari Aalto";
    $URL         = "http://freshmeat.net/projects/perl-dir";

    $OUTPUT_AUTOFLUSH = 1;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#       Resolve a pathname into its shortest version Removing any
#       references to the directory ".", any references to // , any
#       references to directory/.. and any final /
#
#   INPUT PARAMETERS
#
#       $
#	$
#
#   RETURN VALUES
#
#       $
#
# ****************************************************************************

sub resolve ($$)
{
    my ( $file, $direct ) = @ARG;

    $ARG = $file;        # DO NOT 'local' this variable.

    m,^/, || s,^,$direct/,;

    while ( s,/\.?/,/,  or  s,/[^/]+/\.\./,/,  or  s,/\.?$,, )
    {
        #  run the substitutions
    }

    $ARG = '/'  if  $ARG eq "";

    $ARG;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#       Scan a directory and print out the files in each directory in
#	a pretty format. Note: recursive.
#
#   INPUT PARAMETERS
#
#       $
#	$
#
#   RETURN VALUES
#
#       $
#
# ****************************************************************************

sub tree ($$);   # Forward declaration for recursive use.

sub tree ($$)
{
    my ( $dir, $level ) = @ARG;

    unless ( opendir DIRECT, $dir )
    {
        warn "Could not open directory $dir\n";
        return;
    }

    my @files = readdir DIRECT ;
    local $ARG;

    while ( $name = shift @files )
    {
        #  Skip directories .  and  ..
        next if $name =~ /^\.\.?$/;

        resolve $name, $dir;

        if ( -d )
        {
            $newname = $ARG;

            if ( -l $newname )
            {
                 #   Do not follow symlinks

                 $newname = readlink($ARG);
                 print "$level+--$name -> $newname\n";
            }
            elsif ( -r _ && -x _ )
            {
                #   We must be able to enter a directory in order to tree it

                print "$level+--$name/\n";

                if ( @files )
                {
                    tree $newname,"$level|  ";
                }
                else
                {
                    tree $newname,"$level   ";
                }
            }
            else
            {
                print "$level\--$name/ (unreadable)\n";
            }
        }
    }
}


# ****************************************************************************
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
# ****************************************************************************

sub Main ()
{
    $dir = $ARGV[0] || ".";

    print "$dir\n";
    tree $dir, "";
}

Main();

##############################################################################

        # These next few lines are legal in both Perl and nroff.

.00;                    # finish .ig

'di                     \" finish diversion--previous line must be blank
.nr nl 0-1              \" fake up transition to first page again
.nr % 0                 \" start at page 1
'; __END__ ############# From here on it's a standard manual page ############
.TH DDIR 1 "March 9, 1994"
.AT 3
.SH NAME
ddir \- Program to do a DOS like directory tree
.SH SYNOPSIS
.B ddir
.SH DESCRIPTION
.I Ddir
Prints out only directories, not files while recursing down from the
current directory. This is quite slow program to use...
.SH ENVIRONMENT
No environment variables are used.
.SH FILES
None.
.SH AUTHOR
Brian Blackmore
.SH "SEE ALSO"
.SH DIAGNOSTICS
.SH BUGS
.ex
