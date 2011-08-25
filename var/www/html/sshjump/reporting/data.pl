#!/usr/bin/perl

use strict;
use CGI;
use DBI;
#use Config::General;
use CGI::Carp qw(fatalsToBrowser);

use SSHJump::DB::Collection::Log;

$| = 1;

die 'ERROR:  Not running under mod_perl!' unless($ENV{'MOD_PERL'});

my %CONFIG = (
	'DB_NAME' => 'sshjump',
	'DB_USER' => 'sshjump-reports',
	'DB_PASS' => 'iwnffitmk'
);

my $DEBUG  = 0;
#my %CONFIG = Config::General::ParseConfig($ENV{'SSHJUMP_CONF'});
my $CGI    = new CGI;
my $DBH    = DBI->connect( 'dbi:mysql:' . $CONFIG{'DB_NAME'},
                           $CONFIG{'DB_USER'},
                           $CONFIG{'DB_PASS'} );
my $parameters = { DBH => $DBH };
my ($obj, $full_class_name);

print "Content-type: text/html\n\n";

if($DEBUG) {
	foreach my $param ($CGI->param) {
		print $param . ' => ' . $CGI->param($param) . '<br>' . "\n";
	}
}

die 'ERROR:  Class parameter required!' unless($CGI->param('Class'));

$full_class_name = 'SSHJump::DB::Collection::Join::' . $CGI->param('Class');

eval "require " . $full_class_name;
die 'ERROR:  Cannot load ' . $full_class_name . ':' . $@ if($@);

foreach my $param (sort $CGI->param) {
	$parameters->{$param} = $CGI->param($param);
}

$obj = $full_class_name->new($parameters);
print $obj->toJSON;
