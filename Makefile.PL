#! /usr/local/bin/perl

use ExtUtils::MakeMaker;

if ($] < 5.004) {
    die "Perl 5.004 or higher required.\n";
}

## Check Verison .. check for Filter.

WriteMakefile(
	'NAME'      => 'Strict',
	'VERSION'   => '0.10',
        'PREREQ_PM' => {
                       Filter::Util::Call => 0.01
                       },
        'PMLIBDIRS' => ['Strict'],
);

