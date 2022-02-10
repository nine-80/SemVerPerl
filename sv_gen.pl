#!/usr/bin/env perl
# This file is subject to the terms and conditions defined in
# file 'LICENSE.md', found in the root of this repository.
#
# Semantic version (semver.org) generation and validation
#
# Will generate following this format (based on provided options):
# x.y.z[-[dev|alpha|beta|rc]][+<build number>.<short git hash>.<build type>]
# e.g. 0.1.0-dev+14.f76aac6ff363.Debug with -prt, -bt and -gi set
# e.g. 0.1.0 when just provided a version number (just runs through the verification)
#

use strict;
use warnings;
use Config;
use Getopt::Long;
use Pod::Usage;

## Checks to make sure that the generated version matches the semantic versioning rules
sub check_semver_format {
    my ($input_version) = @_;

    my $numbering = '0|[1-9]\d*';
    my $hyphen = q/-/;
    my $any_version = qr/ ($numbering) /x;
    my $version_string = qr/ $any_version[.]$any_version[.]$any_version /x;
    my $pre_release_check = qr/ (?:$numbering|\d*[a-zA-Z-][0-9a-zA-Z-]*) /x;
    my $pre_release =
        qr/ (?:$hyphen($pre_release_check(?:[.]$pre_release_check)*)) /x;
    my $build_meta_check = qr/ [0-9a-zA-Z-]+ /x;
    my $build_meta = qr/ (?:[+]($build_meta_check(?:[.]$build_meta_check)*)) /x;

    my $semantic_version = qr/ ^$version_string$pre_release?$build_meta?$ /x;

    if ($input_version =~ $semantic_version) {
        return 1; # Correct version format provided
    }

    return 0; # Bad version format
}

## Generate the version string from the input to the script
## 'git rev-parse' for HEAD will be the hash for the last commit
sub generate_version {
    my ($provided_version, $pre_release_type, $build_type, $use_git_info) =
        @_;

    # Check to make sure $provided_version is in the correct format
    if ($provided_version !~ m/^[0-9].*\.[0-9].*\.[0-9].*$/) {
        die '[ERROR] Provided version is ill-formed... generation failed';
    }

    # sub in appropriate separator for provided pre-release info
    if ($pre_release_type ne q//) {
        $pre_release_type =~ s/^/-/x;
    }

    # sub in appropriate separator for provided build type
    if ($build_type ne q//) {
        $build_type =~ s/^/./x;
    }

    my $build_meta = "";

    if (defined $use_git_info) {
        ### In order for this to work, there must be a tag in the git repo to count from
        ### These should be version numbers (e.g. added with git tag -a v0.1.0 -m "version comments")
        # Determine which NUL we redirect stderr to (POSIX is /dev/null, Win32 is NUL)
        my $shell_null = $Config{osname} eq "MSWin32" ? "NUL" : "/dev/null";
        my $build_number = qx/git describe --match v$provided_version --dirty 2>$shell_null/ or die '[ERROR] git command failed';

        # strip the tag name (version number) and suffixed hyphen
        $build_number =~ s/v$provided_version-//;
        chomp $build_number;

        if (length($build_number) > 0) {
            $build_meta = qq/+$build_number/;
        } else {
            # This is build number 1 of the new version tag
            my $build_hash = qx/git rev-parse --short=12 HEAD 2>$shell_null/ or die '[ERROR] git command failed';
            chomp $build_hash;
            #$build_type =~ s/./+/x;
            $build_meta = qq/+1.$build_hash/;
        }
    }

    my $version_string =
        $provided_version . $pre_release_type . $build_meta . $build_type;

    check_semver_format($version_string)
        or die "[ERROR] Invalid version string generated: $version_string";
    return $version_string;
}

### Version information record
my %info = (
    provided_version => q//,
    pre_release_type => q//,
    build_type       => q//,
);

### Option flags
my $help = 0;
my $use_git_info = 0;

### Process optional command-line options
GetOptions(
    'help|?'                 => \$help,
    'prt|pre-release-type=s' => \$info{pre_release_type},
    'bt|build-type=s'        => \$info{build_type},
    'gi|use-git-info'        => \$use_git_info
) or pod2usage(2);

pod2usage(2) if $help;
pod2usage(2) if !$ARGV[0];

print generate_version($ARGV[0], $info{pre_release_type}, $info{build_type},
    $use_git_info);

__END__

=head1 SYNOPSIS

sv_gen.pl [options] [major.minor.patch]

 Options:
   -help                            Brief help message
   -prt|pre-release-type <string>   Pre-release information (e.g. dev, alpha, beta, rc)
   -bt|build-type <string>          Build type (e.g. Debug, Release)
   -gi|use-git-info                 Use Git information (build number & hash) in version string

=cut
