#!/usr/bin/perl

use strict;
use DBI;
use Config::General;

use SSHJump::Utils;
use SSHJump::DB::Log;
use SSHJump::DB::Session;

my (@files, $dbh);
my %config = Config::General::ParseConfig($ENV{'SSHJUMP_CONF'});

$dbh = DBI->connect(
  'dbi:mysql:' . $config{'DB_NAME'},
  $config{'DB_USER'},
  $config{'DB_PASS'}
) || die "Cannot connect to database\n";

unless(opendir(LOGS, $config{'SCRIPT_LOG_DIR'})) {
  die 'Cannot open dir ' . $config{'SCRIPT_LOG_DIR'} . ':' .  $!. "\n";
}

@files = grep { /\.log$/ } readdir(LOGS);

closedir(LOGS);

if( ! -d $config{'SCRIPT_LOG_DIR'} . '/archive' ) {
  SSHJump::Utils::prepareDirectory($config{'SCRIPT_LOG_DIR'} . '/archive');
}

if( ! -d $config{'HTML_LOG_DIR'} ) {
  SSHJump::Utils::prepareDirectory($config{'HTML_LOG_DIR'});
}

foreach my $file (@files) {
  # Skip log files that are currently open
  next if(`/usr/sbin/lsof | grep $file | wc -l` > 0);

  # Create static html reports
  my ($base_name, $convert, $archive, $session, $log, $link);

  $base_name = $file;
  $base_name =~ s/\.log$//;

  $session = new SSHJump::DB::Session( { DBH => $dbh } );
  $session->LogFile($config{'SCRIPT_LOG_DIR'} . '/' . $file);
  $session->getSessionFromLogFile();

  next unless($session->SessionID);

  $convert  = 'cat ' . $config{'SCRIPT_LOG_DIR'} . '/' . $file;
  $convert .= ' | /usr/bin/sshjump-ansi2html-fragment > ';
  $convert .= $config{'HTML_LOG_DIR'} . '/' . $base_name . '.html';

  die "Conversion failed!\n" if(system($convert));

  # Archive log and timing files
  $archive  = 'cd ' . $config{'SCRIPT_LOG_DIR'};
  $archive .= ' && ';
  $archive .= 'tar cvf archive/' . $base_name . '.tar ' . $base_name . '.*';
  $archive .= ' && ';
  $archive .=  'bzip2 archive/' . $base_name . '.tar';
  $archive .= ' && ';
  $archive .=  'chmod 600 archive/' . $base_name . '.tar.bz2';
  $archive .= ' && ';
  $archive .=  'chown sshjump:sshjump archive/' . $base_name . '.tar.bz2';
  $archive .= ' && ';
  $archive .=  'rm ' . $base_name . '.*';

  die "Archiving failed!\n" if(system($archive));

  $log = new SSHJump::DB::Log( { DBH => $dbh } );
  $log->SessionID($session->SessionID);
  $log->getUserHostFromSession();

  $link  = '<a id="ScriptLink" ';
  $link .= 'onclick="new SSHJump.ScriptPopUp({url: this.href}).show();';
  $link .= 'return false;" href=' . $config{'REL_HTML_LOG_DIR'};
  $link .= '/' . $base_name . '.html>' . $base_name . '.log</a>';

  $log->info('LOG LINK:  ' . $link);
}

exit 0;
