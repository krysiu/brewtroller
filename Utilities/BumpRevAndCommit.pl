package BumpRevAndCommit 2;
# $Revision 2 $

use strict;
use warnings;
use File::Spec;

$BumpRevAndCommit::VERSION = 0.2;

{
    my $username;
    my $password;
    my $credentials = "svncredentials.txt";
    my $testMode = 0;
    my $inPath = ".";
    
    # process arguments
    #
    while (my $arg = shift @ARGV) {
        if ($arg =~ m/^--h/i || $arg =~ m/^--help/i) {
            printHelp();
            exit; 
        } elsif ($arg =~ m/^--t/i || $arg =~ m/^--test/i) {
            $testMode = 1;
        } elsif ($arg =~ m/^--username/i) {
            $username = shift @ARGV;
        } elsif ($arg =~ m/^--password/i) {
            $password = shift @ARGV;
        } elsif ($arg =~ m/^--credentials/i) {
            $credentials = shift @ARGV;
        } elsif (-e $arg) {
            $inPath = $arg;
        } else {
            if ($arg =~ m/^-+/) {
                print "Invalid argument: $arg\!\n";
            } else {
                print "Invalid commit path: $arg\!\n";
            }
            exit;
        }
    }
    
    # check for username and password
    #
    if (!defined($username)) {
        $username = getCredentials($credentials, "--username");
        if (!defined($username)) {
            print "Enter username : ";
            $username = <>;
        }
    }
    if (!defined($password)) {
        $password = getCredentials($credentials, "--password");
        if (!defined($password)) {
            print "Enter password : ";
            $password = <>;
        }
    }
    
    print "Connecting to SVN...\n";

    # get commit list using svn status (i.e. list of files to commit)
    #
    print "  ... getting commit list";
    my @svnCommitList = getSvnCommitList($inPath);
    print "\n";
    if (checkForConflicts(@svnCommitList)) {
        print @svnCommitList;
        print "Commit list has conflicts which need to be resolved before this\n";
        print "script can do a commit!";
        exit;
    }

    # get next rev using svn info
    #
    print "  ... getting revision";
    my $revision = getSvnRevision();
    print "\n";

    # svn dump
    #
    print "\n";
    print "Commit List (Add, Delete, Modify, Replace)\n";
    foreach (@svnCommitList) {
        print "  $_\n";
        $_ =~ s/.\s*//;     # strip off leading status
    }
    print ("\n");

    # confirmation prompt
    #
    if ($testMode) {
    } else {
        print "Ready to commit revision $revision to SVN\n";
        print "Press \'C\' to continue or \'X\' to exit.\n";
        my $char = <>;
        if ($char !~ m/[cC]/) { exit; }
    }

    # change revision of each project file (project.pde or properties\AssemblyInfo.cs)
    #
    @svnCommitList = sort(@svnCommitList);
    my $lastDir = q{};
    foreach(@svnCommitList) {
        my $dir;
        my $file;
        ($dir, $file) = splitPath($_);
        if ($dir ne $lastDir) {
            setRevision($revision, $dir, $file);
        }
        $lastDir = $dir;
    }


    # execute svn commit command if not in test mode
    #
    if ($testMode) {
        print "\nTest Mode specified! 'svn commit' step has been skipped.\n"; 
        print "   Project files have been changed to reflect svn revisiion.\n"; 
    } else {
        system("svn commit --username $username --password $password --editor-cmd notepad $inPath");
        print "'svn commit' complete!";
    }
    
}

# print help
#
sub printHelp {
    print "Bumps Sketch BUILD or .net project Revision and checks into BrewTroller SVN\n";
    print "  Usage: perl BumpRevAndCommit PATH [options]\n";
    print "\n";
    print "Valid Options:\n";
    print "  directory path     : path of directory to commit (default = '.').\n";
    print "                     :   If no directory is specified, '.' is used.\n";
    print "  --username ARG     : svn User ID\n";
    print "  --password ARG     : svn User password\n";
    print "  --credentials ARG  : path to file w/credentials (2 lines - --username ID, --password PW\n";
    print "                     :    If no credential file is specified, 'svncredentials.txt is used.\n";
    print "  --test             : test mode, updates file revesion but does not do svn commit\n";
    print "  --h (or help)      : print help info\n";
    print "\n";
    print "  Examples\n";
    print "    BumpRevAndCommit crewTroller\n";
    print "    BumpRevAndCommit -h to display help\n";
    return;
}

# get a credential (username or password) from a file
#
sub getCredentials {
    my ($credentialFile, $credentialName) = @_;
    my $credentialValue;
    my $file;
    if (defined($credentialFile) && -e $credentialFile && open($file, q{<}, $credentialFile)) {
        while (<$file>) {
            if (m/^\s*$credentialName\s+(.*)\s/i) {
                $credentialValue = $1;
                last;
            }
         }
        close $file;
    }
    return $credentialValue;
}
    
# get the list of file to be committed using the svn status command
#
# ' ' No Modifications
#  A - Addition				X - External Definition	
#  D - Deletion				I - Ignored
#  M - Modified				? - Not Under SVN
#  R - Replaced				! - Missing
#  C - Conflict (contents)	~ - One of a kind
#  
sub getSvnCommitList {
    my ($inPath) = @_;
    my $statusFileName = "svnStatus.txt";
    my $statusFile;
    my @svnCommitList;

    system("svn status $inPath > $statusFileName");
    if (!open($statusFile, q{<}, $statusFileName)) {
        die "Unable to open $statusFileName.\n";
    }
    while (<$statusFile>) {
        chomp($_);
        if ($_ =~ m/^([admrc])/i) {
            push(@svnCommitList, $_);
        }
    }

    close($statusFile);
    unlink($statusFileName);
    return @svnCommitList;
}

# get the current revision using the svn info command
#
sub getSvnRevision {
    my $revision = 0;
    my $infoFileName = "svnInfo.txt";
    my $infoFile;
    
    system("svn info http://brewtroller.googlecode.com/svn/ > $infoFileName");
    if (!open($infoFile, q{<}, $infoFileName)) {
        die "Unable to open $infoFileName.";
    }
    while (<$infoFile>) {
        if (m/Revision:\s*(\d*)/) {
            $revision = $1 + 1;
            last;
        }
    }
    
    if ($revision == 0) {
        die "\nRevision not found from svn info\n";
    }
    
    close($infoFile);
    unlink($infoFileName);
    return $revision;
}

# check commit list for Conflict status
#
sub checkForConflicts {
    my (@svnCommitList) = @_;
    foreach (@svnCommitList) {
        if (m/^([c])/) {
            #print "Conflict\n";
            return 1;
        }
    }
    return 0;
}

# get the directory name from a file path
#
sub splitPath {
    my ($path) = @_;
    my $dir;
    my $file;
    if ( $path =~ m!^(.*)\\([^\\]*)$! ) {
        # have a match, $1 and $2 are valid
        $dir = $1;
        $file = $2;
    } else {
        # no match so there is no '\' in the path
        $dir = q{.};     # '.' is the current directory;
        $file = $path;
    }
    return ($dir, $file);
}

# get the current revision using the svn info command
#
sub setRevision {
    my ($rev, $dir, $file) = @_;
    my $projFile;

    $projFile = pdeCheck($dir, $file);
    if ($projFile ne q{}) {
        setRevisionInArduinoProject($rev, $projFile);
    }

    $projFile = vsCheck($dir);
    if ($projFile ne q{} ) {
        setRevisionInVisualStudioProject($rev, $projFile);
    }
    return;
}

# check if file to process is part of a Arduino project
#
sub pdeCheck {
    my ($dir, $file) = @_;
    # for sketchs, project file = directory
    my $projName = $dir;
    $projName =~ s/^.*\\//;
    my $projFileName =  $dir . "\\" . $projName . ".pde";
    
    if (! -e $projFileName) { return q{}; }
        
    return $projFileName;
}

# check if file to process is part of a VS project
#
sub vsCheck {
    my ($dir) = @_;
    my $projFile;
    
    # recurse up the directory tree looking for a csproj or vbproj file
    my $safetyValve = 0;
    while ($dir ne q{}) {
        my @projFile = glob $dir."\\*.csproj";
        if (!@projFile) {
            @projFile = glob "*\\*.vbproj";
        }
        if (@projFile) { last; }
        my $index = rindex($dir, q{\\});
        if ($index < 0) {
            $dir = q{};
        } else {
            $dir = substr($dir, 0, $index)
        }
        $safetyValve++;
        if ($safetyValve > 10) { last; }
    }
    
    if($dir eq q{}) { $dir = "Properties"; }
    $projFile = $dir."\\Properties\\AssemblyInfo.cs";

    if (! -e $projFile) { return q{}; }
        
    return $projFile;
}

# set revision number in a Arduion Sketch project
#
sub setRevisionInArduinoProject {
    my ($rev, $projFileName) = @_;
    print "Set Revision $rev in Arduino $projFileName\n";
    
    my $projFile;
    if (!open($projFile, q{<}, $projFileName)) {
        die "\nUnable to open $projFileName\n";
    }

    my $tempFileName = "buildMaster.pde";
    my $tempFile;
    if (!open ($tempFile, q{>}, $tempFileName)) {
        die "\nUnable to open $tempFileName\n";
    }
    
    while (<$projFile>) { 
        if (m/^#define\s+BUILD/) {
            print $tempFile "#define BUILD $rev\n";
        } else {
            print $tempFile $_;
        }
    }
    
    close $projFile;
    close $tempFile;
    
    unlink $projFileName;
    rename $tempFileName, $projFileName;
    return;
}

# set revision number in a VisualStudio assembly
#
sub setRevisionInVisualStudioProject {
    my ($rev, $projFileName) = @_;
    print "Set Revision $rev in VisualStudio $projFileName\n";
    
    my $projFile;
    if (!open($projFile, q{<}, $projFileName)) {
        die "\nUnable to open $projFileName\n";
    }
		
    my $tempFileName = $projFileName . ".temp";
    my $tempFile;
    if (!open ($tempFile, q{>}, $tempFileName)) {
        die "\nUnable to open $tempFileName\n";
    }
    
    while (<$projFile>) {
        if (m!^[^/+].*(AssemblyVersion|AssemblyFileVersion)!xi) {
            # pick out the version info Major.Minor.Build.Revision
            m!\"(\d+)\.(\d+)\.(\d+)\.(\d+)\"!;
            # if revision == $rev, this file has already been changed
            if ($4 eq $rev) {
                close $projFile;
                close $tempFile;
                unlink $tempFileName;
                return;
            }
            # bump build by 1
            my $build = $3 + 1;
            # substitue new info
            $_ =~ s!"(\d+)\.(\d+)\.(\d+)\.(\d+)\"!\"$1.$2.$build.$rev\"!ix;
        }
        print $tempFile $_;
    }
    
    close $projFile;
    close $tempFile;
    
    unlink $projFileName;
    rename $tempFileName, $projFileName;
    return;
}

1;