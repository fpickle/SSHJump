#!/usr/bin/perl

use strict;
use DBI;
use Getopt::Long;

use SSHJump::Verify::Host;
use SSHJump::Verify::AlphaNumeric;
use SSHJump::System::Host;

my ($dbh, $vhost, $vcustomer, $valias);
my ($host_obj, @aliases, $file, $help);

my $result = GetOptions( 'help|h'   => \$help,
                         'file|f=s' => \$file );

&usage() if(!$result || $help);

unless(open(FILE, '<' . $file)) {
  print 'Cannot open ' . $file . ": $!\n";
  exit 1;
}

while(my $line = <FILE>) {
  my ($hostname, $customer, $aliases) = split(/\|/, $line);

  $dbh = DBI->connect('dbi:mysql:sshjump', 'root', '');
  $vhost = new SSHJump::Verify::Host( { Host => $hostname } );
  $vcustomer = new SSHJump::Verify::AlphaNumeric( { String => $customer } );

  unless($vhost->verify()) {
    print 'Invalid host string' . "\n";
    next;
  }

  unless($vcustomer->verify()) {
    print 'Invalid customer string' . "\n";
    next;
  }

  $host_obj = new SSHJump::System::Host( { DBH => $dbh } );

  $host_obj->HostName($hostname);
  $host_obj->Customer($customer);

  unless($host_obj->resolves()) {
    print 'Host ' . $host_obj->HostName . ' does not resolve' . "\n";
    next;
  }

  unless($host_obj->addHost()) {
    print 'Could not add host' . "\n";
    next;
  }

  $aliases =~ s/\s//g;
  @aliases = split(/,/, $aliases);

  foreach my $alias (@aliases) {
    my $valias = new SSHJump::Verify::Host( { Host => $hostname } );
    next unless($valias->verify());
    $host_obj->addAlias($alias);
  }
}

$dbh->disconnect();
close(FILE);

exit 0;

sub usage {
  my ($msg) = @_;

  print "\n";
  print $msg . "\n\n" if($msg);
  print 'Usage:' . "\n";

  print '    ' . $0 . ' -f <file>' . "\n";
  print "\n";

  print 'Options:' . "\n";
  print "  --help\t"   . 'Print this help message' . "\n";
  print "  --file|f\t" . 'File to parse' . "\n";
  print "\n";
  exit 0;
}
