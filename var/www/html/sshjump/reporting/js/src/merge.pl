#!/usr/bin/perl

use strict;

my $js_file = 'application.js';
my (@dirs, @files);

system('rm ../' . $js_file) if(-f '../' . $js_file);

opendir(DIRS, '.') || die "Cannot read directory";
@dirs = grep { !/^\./ } readdir(DIRS);
closedir(DIRS);

foreach my $dir (sort { $a <=> $b } @dirs) {
	next unless(-d $dir);

	opendir(FILES, $dir) || die "Cannot open directory " . $dir;
	@files = grep { !/^\./ } readdir(FILES);
	closedir(FILES);

	foreach my $file (sort { $a <=> $b } @files) {
		system('echo "/**** Begin ' . $file . ' ****/" >> ../' . $js_file); 
		system('cat ' . $dir . '/' . $file . ' >> ../' . $js_file);
		system('echo "/**** End ' . $file . ' ******/" >> ../' . $js_file); 
	}
}
