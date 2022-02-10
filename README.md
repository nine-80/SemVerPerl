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

## License

```text
Copyright 2022 nine|eighty. All rights reserved

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE
```
