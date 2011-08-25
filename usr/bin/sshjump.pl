#!/usr/bin/perl

use strict;

use DBI;
use Getopt::Long;
use Config::General;

use SSHJump::Cmd;

my %config = Config::General::ParseConfig($ENV{'SSHJUMP_CONF'});
my ($help, $server, $user, $copy, $list, $to, $dbh);
my ($o_cmd, $type, $service, $message, $o_verify, $execute);
my ($list_by, $list_search);
my $result = GetOptions( 'help'        => \$help,
                         'host|h=s'    => \$server,
                         'user|u=s'    => \$user,
                         'copy|c=s'    => \$copy,
                         'to|t=s'      => \$to,
                         'type=s'      => \$type,
                         'restart|r=s' => \$service,
                         'execute|e=s' => \$execute,
                         'message|m=s' => \$message,
                         'list|l'      => \$list,
                         'by|b=s'      => \$list_by,
                         'search|s=s'  => \$list_search );

### Check Required Input #######################################################
&usage() if(!$result || $help);

if($list) {
  $message = 'List User Access' if(!$message);
  $user = '';
} else {
  &usage('--message required') unless($message || $list);

  if($message =~ m/^\s+$/) {
    &usage('--message must contain more than just whitespace');
  }

  if(length($message) < 4) {
    &usage('--message must contain at least 4 characters');
  }

  &usage('--server and --user required') unless($server && $user);
}

### Initialization #############################################################
$dbh = DBI->connect(
   'dbi:mysql:' . $config{'DB_NAME'},
  $config{'DB_USER'},
   $config{'DB_PASS'}
) || die "Cannot connect to database\n";

# Script inputs ($server, $message, $user) are 
# verified by the SSHJump::Cmd object...
$o_cmd = new SSHJump::Cmd( {
  DBH        => $dbh,
  Config     => \%config,
  Host       => $server ? $server : $ENV{'HOSTNAME'},
  Reason     => $message,
  RemoteUser => $user
} );

if($list) {
  ### Print Access List ########################################################
  $o_cmd->list($list_by, $list_search);
} elsif($service) {
  ### Restart Service ##########################################################
  # $service string will be verified by the SSHJump::Cmd object...
  $o_cmd->Service($service);
  $o_cmd->restart();
} elsif($execute) {
  ### Execute Remote Command ###################################################
  $o_cmd->RemoteCommand($execute);
  $o_cmd->execute();
} elsif($copy) {
  ### Copy #####################################################################
  &usage('--copy and --to values are required') unless($copy && $to);
  $type = 'ssh' unless($type);

  # $type, $copy, $to strings will be verified by the SSHJump::Cmd object...
  $o_cmd->Type($type);
  $o_cmd->From($copy);
  $o_cmd->To($to);
  $o_cmd->copy();
} else {
  ### SSH ######################################################################
  $o_cmd->connect();
}

exit 0;

END {
  if($o_cmd) {
    $o_cmd->Log->info('CLOSE SESSION (CMD):  ' . $o_cmd->CurrentUser);
    $o_cmd->Session->close() if($o_cmd->Session);
  }

  $dbh->disconnect() if($dbh);
}

################################################################################

sub usage {
  my ($msg) = @_;

  print "\n";
  print $msg . "\n\n" if($msg);
  print 'Usage:' . "\n";

  print '  List Access Permissions:' . "\n";
  print '    ' . $0 . ' -l' . "\n";

  print '  SSH to Remote Host:' . "\n";
  print '    ' . $0 . ' -h <hostname> -u <remote user> -m <reason>' . "\n";

  print '  SCP files to/from Remote Host:' . "\n";
  print '    ' . $0 . ' -h <hostname> -u <remote user>';
  print ' -c <file/dir to copy> -t <file/dir destination>';
  print ' --type <ssh|rsync> -m <reason>' . "\n";

  print '  Print Help:' . "\n";
  print '    ' . $0 . ' --help' . "\n";

  print '  Restart Remote Service:' . "\n";
  print '    ' . $0 . ' -h <hostname> -u <remote user> -r <service>';
  print ' -m <reason>' . "\n";

  print "\n";
  
  print 'Options:' . "\n";
  print "  --help\t" . 'Print this help message' . "\n";
  print "  --host|-h\t" . 'The host name or alias to connect to' . "\n";
  print "  --user|-u\t" . 'The remote user to connect as' . "\n";
  print "  --message|-m\t" . 'Give a reason for your use of this script' . "\n";
  print "  --list|-l\t" . 'List all hosts you have access to' . "\n";
  print "  --by|-b\t" . 'Group by function used with the -l option.  ';
  print 'Will accept \'group\' or \'customer\'' . "\n";
  print "  --search|-s\t" . 'Specify a search string to be used with the -b ';
  print 'option' . "\n";
  print "  --copy|-c\t" . 'File/directory to copy.  Follows standard scp ';
  print 'syntax; ie. host:/from/file/path' . "\n";
  print "  --to|-t\t" . 'File/directory destination.  Follows standard scp ';
  print 'syntax; ie. host:/from/file/path' . "\n";
  print "  --type\t" . 'Defines what type of copy command to issue ';
  print '(ssh or rsync).  Defaults to ssh' . "\n";
  print "  --restart\t" . 'Service to restart' . "\n";
  print "\n";
  exit 0;
}
