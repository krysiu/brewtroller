package BumpRevAndCommit 1;
# $Revision 1 $

use strict;
use warnings;
use File::Spec;

$BumpRevAndCommit::VERSION = 0.1;

{
    my $userID = 'tomontee@gmail.com';
    my $password = 'vS7sY9aS5Jd6';

    my $inPath = shift(@ARGV);
    if (! defined($inPath)) {
        print "Directory must be specified\n\n";
        printHelp();
        exit; 
    } elsif ($inPath eq "-h") {
        printHelp();
        exit;
    }   
    
    my $temp = shift(@ARGV);
    if (defined($temp)) {
        $userID = $temp;
    } elsif (!defined($userID)) {
        print "Enter User ID : ";
        $userID = <>;
    }

    $temp = shift(@ARGV);
    if (defined($temp)) {
        $password = $temp;
    } elsif (!defined($password) ) {
        print "Enter Password: ";
        $password = <>;
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
    print "Commit List (Add, Delete, Modify, Replace\n";
    print "\nx\n";
    foreach (@svnCommitList) {
        print "  $_\n";
        $_ =~ s/.\s*//;     # strip off leading status
    }
    print ("\n");

    # confirmation prompt
    #
    print "Ready to commit revision $revision to SVN\n";
    print "Press \'C\' to continue or \'X\' to exit.\n";
    my $char = <>;
    if ($char !~ m/[cC]/) { exit; }

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


    # execute svn commit command with commit comment editor option
    system("svn commit --username $userID --password $password --editor-cmd notepad $inPath");
}

# print help
#
sub printHelp {
    print "Bumps Sketch or .net project and checks into BrewTroller SVN\n";
    print "  Usage\n";
    print "    arg[0] - directory\n";
    print "    arg[1] - login\n";
    print "    arg[2] - password\n";
    print "\n";
    print "  Examples\n";
    print "    BumpRevAndCommit crewTroller\n";
    print "    BumpRevAndCommit -h to display help\n";
    return;
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
    open($statusFile, q{<}, $statusFileName);
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
    open($infoFile, q{<}, $infoFileName);
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

    print "Directory: $dir\n";
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
        if (!defined(@projFile)) {
            @projFile = glob "*\\*.vbproj";
        }
        if (defined(@projFile)) { last; }
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

sub setRevisionInArduinoProject {
    my ($rev, $projFileName) = @_;
    print "Set Revision $rev in Arduino $projFileName\n";
    
    my $projFile;
    if (!open($projFile, q{<}, $projFileName)) {
        die "Unable to open $projFile\n";
    }

    my $tempFileName = "buildMaster.pde";
    my $tempFile;
    open ($tempFile, q{>}, $tempFileName);
    
    while (<$projFile>) { 
        if (m/^BUILD/) {
            print $tempFile "BUILD $rev\n";
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

sub setRevisionInVisualStudioProject {
    my ($rev, $projFileName) = @_;
    print "Set Revision $rev in VisualStudio $projFileName\n";
    
    my $projFile;
    if (!open($projFile, q{<}, $projFileName)) {
        die "Unable to open $projFile\n";
    }
		
    my $tempFileName = $projFileName . ".temp";
    my $tempFile;
    open ($tempFile, q{>}, $tempFileName);
    
    while (<$projFile>) {
        if (m!^[^/+].*(AssemblyVersion|AssemblyFileVersion)!xi) {
            m!\"(\d+)\.(\d+)\.(\d+)\.(\d+)\"!;
            my $build = $3 + 1;
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