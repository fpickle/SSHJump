#!/usr/bin/perl

use strict;
use DBI;
use Getopt::Long;
use Config::General;

use SSHJump::DB::Log;
use SSHJump::DB::Collection::Session;

my ($help, $file);
my %config = Config::General::ParseConfig($ENV{'SSHJUMP_CONF'});

my $dbh = DBI->connect(
  'dbi:mysql:' . $config{'DB_NAME'},
  $config{'DB_USER'},
  $config{'DB_PASS'}
) || die "Cannot connect to database\n";

my $result = GetOptions( 'help|h'   => \$help,
                         'file|f=s' => \$file );

&usage() if(!$result || $help);

if($file) {
  unless(open(FILE, '<' . $file)) {
    print 'Cannot open ' . $file . ": $!\n";
    exit 1;
  }

  while(my $line = <FILE>) {
    chomp($line);

    my ($host, $user, $time, $pid, $o_session);
    my ($session_id, $log_file) = split(/\|/, $line);

    if($log_file =~ m/^(.*)-(\w+)-(\d+)-(\d+).log$/) {
      $host = $1;
      $user = $2;
      $time = $3;
      $pid  = $4;
    }

    next unless($pid);
    next if(`ps -ef | awk '{print \$2}' | grep $pid | wc -l` > 0);

    $o_session = new SSHJump::DB::Session( {
      DBH       => $dbh,
      SessionID => $session_id
    } );

    $o_session->getSessionFromID();
    $o_session->LogFile($config{'SCRIPT_LOG_DIR'} . '/' . $log_file);
    $o_session->close();
  }

  close(FILE);
} else {
  my $sql = 'select ADDDATE(NOW(), INTERVAL -1 HOUR)';
  my $timestamp = `mysql -uroot -s sshjump -e '$sql'`;
  chomp($timestamp);

  # Exit if sshjump-admin is running...
  my @psef = `ps -ef | grep -v grep | grep sshjump-admin`;

  exit 0 if(@psef);

  my $c_session = new SSHJump::DB::Collection::Session( {
    DBH        => $dbh,
    Type       => 'APP',
    Status     => 'OPEN',
    TimeOpened => $timestamp
  } );

  if(defined $c_session->Collection) {
    foreach my $o_session (@{$c_session->Collection}) {
      my $log = new SSHJump::DB::Log( { DBH => $dbh } );

      $log->SessionID($o_session->SessionID);
      $log->getUserHostFromSession();

      $log->warning('Session open with no application running...forcing closure');
      $o_session->close();
    }
  }
}

exit 0;

END {
  $dbh->disconnect() if($dbh);
}

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
