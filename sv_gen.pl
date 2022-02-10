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

### Version information record
my %info = (
    provided_version => q//,
    pre_release_type => q//,
    build_type       => q//,
    build_num        => q//,
);

## Generate the version string from the input to the script
## 'git rev-parse' for HEAD will be the hash for the last commit
sub generate_version {
    my ($provided_version, $use_git_info) = @_;

    # Check to make sure $provided_version is in the correct format
    if ($provided_version !~ m/^[0-9].*\.[0-9].*\.[0-9].*$/) {
        die '[ERROR] Provided version is ill-formed... generation failed';
    }

    # sub in appropriate separator for provided pre-release info
    my $pre_release_type = $info{pre_release_type};
    if ($pre_release_type ne q//) {
        $pre_release_type =~ s/^/-/x;
    }

    # sub in appropriate separator for provided build type
    my $build_type = $info{build_type};
    if ($build_type ne q//) {
        $build_type =~ s/^/./x;
    }

    my $build_meta = "";

    if ($use_git_info) {
        # Determine which NUL we redirect stderr to (POSIX is /dev/null, Win32 is NUL)
        my $shell_null = $Config{osname} eq "MSWin32" ? "NUL" : "/dev/null";

        # strip the tag name (version number) and suffixed hyphen
        my $build_number = $info{build_num};

        my $build_hash = qx/git rev-parse --short=12 HEAD 2>$shell_null/ or die '[ERROR] git command failed';
        chomp $build_hash;

        if (length($build_number) > 0) {
            $build_meta = qq/+$build_number.$build_hash/;
        }
        else {
            # Not using a build number
            $build_meta = qq/+$build_hash/;
        }
    }

    my $version_string =
        $provided_version . $pre_release_type . $build_meta . $build_type;

    check_semver_format($version_string)
        or die "[ERROR] Invalid version string generated: $version_string";
    return $version_string;
}

### Option flags
my $help = 0;
my $use_git_info = 0;

### Process optional command-line options
GetOptions(
    'help|?'                 => \$help,
    'prt|pre-release-type=s' => \$info{pre_release_type},
    'bt|build-type=s'        => \$info{build_type},
    'bn|build-num=i'         => \$info{build_num},
    'gi|use-git-info'        => \$use_git_info
) or pod2usage(2);

pod2usage(2) if $help;
pod2usage(2) if !$ARGV[0];

print generate_version($ARGV[0], $use_git_info);

__END__

=head1 SYNOPSIS

sv_gen.pl [options] major.minor.patch

 Options:
   -help                            Brief help message
   -prt|pre-release-type <string>   Pre-release information (e.g. dev, alpha, beta, rc)
   -bt|build-type <string>          Build type (e.g. Debug, Release)
   -bn|build-num <int>              Build number
   -gi|use-git-info                 Use Git information (commit short hash) in version string

=cut
