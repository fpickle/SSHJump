#!/usr/bin/perl

use strict;
use DBI;
use Config::General;

use SSHJump::App::Handlers;
use SSHJump::App::Control::Info;

### Globals ####################################################################
my %CONFIG   = Config::General::ParseConfig($ENV{'SSHJUMP_CONF'});
my $DBH      = DBI->connect( 'dbi:mysql:' . $CONFIG{'DB_NAME'},
                             $CONFIG{'DB_USER'},
                             $CONFIG{'DB_PASS'} );

die "No configuration data\n"           unless(%CONFIG);
die "Cannot open database connection\n" unless($DBH);

# $PROGRAM calls a wrapper class for all the dialog handlers.
# Initially, I moved the dialog functions out of this script
# for better organization.  However, this is a very kludgy
# solution and needs to be re-worked...
my $PROGRAM = new SSHJump::App::Handlers( {
  DBH           => $DBH,
  EscapeHandler => \&escapeExecution,
  Config        => \%CONFIG,
  ExitHandler   => \&exitProgram,
  Host          => $ENV{'HOSTNAME'}
} );

### Main #######################################################################
$PROGRAM->mainMenu();
$PROGRAM->Log->info('CLOSE SESSION (APP):  ' . $PROGRAM->CurrentUser);
exit(0);

END {
  print "\nDisconnecting...\n";
  $PROGRAM->Session->close() if($PROGRAM && $PROGRAM->Session);
  $DBH->disconnect() if($DBH);
}

################################################################################

sub escapeExecution {
  my $control = new SSHJump::App::Control::Info( { Config => \%CONFIG } );

  $control->Text('ESCape caught, leaving program...');
  $control->show();

  &exitProgram();
}

sub exitProgram {
  $PROGRAM->Log->info('CLOSE SESSION (APP):  ' . $PROGRAM->CurrentUser);
  exit 0;
}

#sub view_hist {
#    $input="";
#
#    system("clear");
#    system("dialog --title 'Enter Username' --inputbox '\nPlease enter the username you wish to view\n' 10 60 2> $tempfile");
#
#    open (INPUT, "$tempfile");
#        while (<INPUT>) {
#            $input=$_;
#        }
#    close INPUT;
#
#    unlink $tempfile;
#
#    system("/usr/bin/vi /data0/histories/$input.hist");
#    return;
#}
