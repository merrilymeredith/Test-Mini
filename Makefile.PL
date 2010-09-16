use strict;
use warnings;

BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.31;
use ExtUtils::Manifest  1.56;

my $SKIP_FILES = <<SKIP;
SKIP

my %WriteMakefileArgs = (
    'NAME'     => 'Test::Mini',
    'ABSTRACT' => 'Lightweight xUnit Testing for Perl',
    'VERSION'  => 'v0.6.0_2',
    'AUTHOR'   => 'Pieter van de Bruggen <pvande@cpan.org>',
    'LICENSE'  => 'perl',
    'PREREQ_PM' => {
        'Try::Tiny'        => '0.04',
        'Scalar::Util'     => '1.21',
        'List::Util'       => '1.21',
        'List::MoreUtils'  => '0.22',
        'MRO::Compat'      => '0.10',
        'Getopt::Long'     => '2.38',
        'Time::HiRes'      => '1.9719',
        'Exception::Class' => '1.30',
        'namespace::clean' => '0.14',
        'Data::Inspect'    => '0.03',
        'Text::Outdent'    => '0.01',
    },
    'BUILD_REQUIRES' => {
        'Test::More' => '0.96',
        'B'          => '0',
        'aliased'    => '0.30',
        'IO::Scalar' => '2.110',
    },
    'CONFIGURE_REQUIRES' => {
         'ExtUtils::MakeMaker' => '6.31',
         'ExtUtils::Manifest'  => '1.56',
    },
#   'DIST_REQUIRES' => {
#       'ShipIt'                 => '0.55',
#   },
    'test' => {
        'TESTS' => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t t/*/*/*/*/*.t',
    },
    'dist' => {
        'PREOP'  => '',
        'POSTOP' => 'make realclean; rm MANIFEST',
    },
);

delete $WriteMakefileArgs{BUILD_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.56) };

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

(my $DISTNAME = $WriteMakefileArgs{NAME}) =~ s/::/-/g;

# Create a MANIFEST.SKIP file.
open(GITIGNORE, '<.gitignore');
open(SKIP, '>MANIFEST.SKIP');
print SKIP "#!include_default\n";
print SKIP "MANIFEST.SKIP.*\n";
print SKIP "^$DISTNAME.*\n";
print SKIP <GITIGNORE>;
print SKIP $SKIP_FILES;
close SKIP;
close GITIGNORE;

# Create a new MANIFEST.
ExtUtils::Manifest::mkmanifest();

# Write the new Makefile.
WriteMakefile(%WriteMakefileArgs);

# Cleanup the MANIFEST.SKIP files.
unlink glob 'MANIFEST.{,SKIP}*';