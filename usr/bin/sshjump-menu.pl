#!/usr/bin/perl

use strict;

use DBI;
use Getopt::Long;
use Config::General;

use SSHJump::Cmd;

my %config = Config::General::ParseConfig($ENV{'SSHJUMP_CONF'});
my ($help, $o_cmd, $dbh, $menu);
my $result = GetOptions( 'help|h' => \$help );

&usage() if(!$result || $help);

### Initialization #############################################################
$dbh = DBI->connect(
   'dbi:mysql:' . $config{'DB_NAME'},
  $config{'DB_USER'},
   $config{'DB_PASS'}
) || die "Cannot connect to database\n";

$menu = &getMenu($dbh, \%config);

while(1) {
  my ($choices, $answer);
  $choices = &printCustomerMenu($menu);

  print "Please choose a customer from the list\n";
  print "above or press any other key to exit:\n";

  $answer = <STDIN>;
  chomp($answer);

  last if($answer !~ m/^\d+$/);
  last unless(&confirm($choices->[$answer]));

  $choices = &printServerMenu($menu, $choices->[$answer]);

  print "Please choose a server from the list above or press\n";
  print "any other key to return to the previous menu:\n";

  $answer = <STDIN>;
  chomp($answer);

  next if($answer !~ m/^\d+$/);
  next unless(&confirm($choices->[$answer]));

  &connect($dbh, \%config, $choices->[$answer]);
}

exit 0;

END {
  $dbh->disconnect() if($dbh);
}

################################################################################

sub usage {
  my ($msg) = @_;

  print "\n";
  print $msg . "\n\n" if($msg);
  print 'Usage:  ' . $0 . ' [--help|-h]' . "\n";
  print "\n";
  print 'Options:' . "\n";
  print "  --help|-h\t" . 'Print this help message' . "\n";
  print "\n";
  exit 0;
}

sub parseAccessList {
  my ($list) = @_;
  my $menu = {};

  foreach my $entry (@{$list}) {
    my $customer = $entry->[4];
    push @{$menu->{$customer}}, $entry;
  }

  return $menu;
}

sub getMenu {
  my ($dbh, $config) = @_;
  my ($menu);

  $o_cmd = new SSHJump::Cmd( {
    DBH        => $dbh,
    Config     => $config,
    Host       => $ENV{'HOSTNAME'},
    Reason     => 'List User Access'
  } );

  $menu = &parseAccessList($o_cmd->AccessList);

  $o_cmd->Log->info('CLOSE SESSION (CMD):  ' . $o_cmd->CurrentUser);
  $o_cmd->Session->close() if($o_cmd->Session);

  return $menu;
}

sub printCustomerMenu {
  my ($menu) = @_;
  my $count = 1;
  my ($choices);

  system('clear');
  &header();

  print "\n";

  foreach my $customer (sort keys %{$menu}) {
    $choices->[$count] = $customer;
    &format($count++, $customer);
  }

  print "\n";
  return $choices;
}

sub printServerMenu {
  my ($menu, $customer) = @_;
  my $count = 1;
  my ($choices);

  system('clear');
  &header();

  print "\n";

  foreach my $server (@{$menu->{$customer}}) {
    $choices->[$count] = $server;
    &format($count++, 'Connect to ' . $server->[1] . ' as ' . $server->[2]);
  }

  print "\n";
  return $choices;
}

sub connect {
  my ($dbh, $config, $params) = @_;
  my ($obj, $reason);

  system('clear');

  while(!length($reason)) {
    print "Please enter your reason for making this connection:\n";
    $reason = <STDIN>;
    chomp($reason);
  }

  $obj = new SSHJump::Cmd( {
    DBH        => $dbh,
    Config     => $config,
    Host       => $params->[1],
    Reason     => $reason,
    RemoteUser => $params->[2]
  } );

  $obj->connect();

  $obj->Log->info('CLOSE SESSION (CMD):  ' . $obj->CurrentUser);
  $obj->Session->close() if($obj->Session);
}

sub format {
  my ($number, $label) = @_;
  printf '%-4s%s', $number . '.', $label . "\n";
}

sub header {
  print "==================================\n";
  format STDOUT =
@<@|||||||||||||||||||||||||||||@>
"|", "SSHJump : CONNECT MENU", "|"
.
  write;
  print "==================================\n\n";
}

sub confirm {
  my ($customer) = @_;
  return 0 unless($customer);
}

sub getReason {
  system('clear');

  print
}
