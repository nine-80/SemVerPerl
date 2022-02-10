# Semantic Versioning

Perl script to provide semantic version generation and validation based on the rules from [semver.org](https://semver.org/).

Will generate a version string following the below format (based on provided options):

`x.y.z[-[dev|alpha|beta|rc]][+<build number>.<short git hash>.<build type>]`

## Usage

```text
sv_gen.pl [options] major.minor.patch

 Options:
   -help                            Brief help message
   -prt|pre-release-type <string>   Pre-release information (e.g. dev, alpha, beta, rc)
   -bt|build-type <string>          Build type (e.g. Debug, Release)
   -gi|use-git-info                 Use Git information (build number & hash) in version string
```
