package SSHJump::Cmd;

use Moose;

use SSHJump::Moose::Types;

use SSHJump::Utils;
use SSHJump::DB::Log;
use SSHJump::DB::Session;
use SSHJump::DB::SSHKey;
use SSHJump::DB::User;
use SSHJump::DB::Collection::UserGroup;
use SSHJump::DB::Collection::HostGroup;
use SSHJump::System::Call::Script::SCP;
use SSHJump::System::Call::Script::SSH;
use SSHJump::System::Call::Script::Rsync;
use SSHJump::System::Call::Script::Service;
use SSHJump::System::Call::Script::RemoteCommand;

### Class Properties ###########################################################
# Database Handle
has 'DBH'           => ( is => 'rw', isa => 'Object', required => 1 );

# String Properties
has 'CurrentUser'   => ( is => 'ro', isa => 'CleanStr', default => '' );
has 'From'          => ( is => 'rw', isa => 'PathStr', default => ''  );
has 'Reason'        => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'RemoteCommand' => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'RemoteUser'    => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'Service'       => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'To'            => ( is => 'rw', isa => 'PathStr', default => ''  );
has 'Type'          => ( is => 'rw', isa => 'CleanStr', default => '' );

has 'Host' => (
  is      => 'rw',
  isa     => 'CleanStr',
  default => '',
  trigger => \&_verifyHost
);

# Configuration HashRef
has 'Config'      => ( is => 'rw', isa => 'HashRef', required => 1 );

# List Properties
has 'AccessList'  => ( is => 'ro', isa => 'ArrayRef');

# Object Properties
has 'Log'         => ( is => 'ro', isa => 'Log'     );
has 'Session'     => ( is => 'ro', isa => 'Session' );

### Public Method Definitions ##################################################
sub connect {
  my ($self) = @_;
  my ($o_cmd, $key);

  unless($self->AccessList) {
    $self->Log->warning($self->CurrentUser . ' does not have shell access');
    print STDERR "You do not have shell access\n";
    return;
  }

  $key = $self->_getKeyFromAccessList();

  unless($key) {
    $self->Log->warning($self->CurrentUser . ' cannot access ' . $self->Host);
    print STDERR 'You do not have access to ' . $self->Host;
    print STDERR ' as ' . $self->RemoteUser . "\n";
    return;
  }

  $self->Log->info('Opening SSH session: ' . $self->_connectStr());

  $o_cmd = new SSHJump::System::Call::Script::SSH( {
    LogDir     => $self->Config->{'SCRIPT_LOG_DIR'},
    User       => $self->CurrentUser,
    Host       => $self->Host,
    RemoteUser => $self->RemoteUser,
    Key        => $key,
    Log        => $self->Log
  } );

  $o_cmd->execute();

  if($o_cmd->ExitCode) {
    my $msg = 'SSH exited with status ' . $o_cmd->ExitCode;
    $self->Log->error($msg);
    print STDERR 'An error has occurred.  ' . $msg . "\n";
  }

  $self->Session->LogFile($o_cmd->FileBase . '.log');
  $self->Log->info('Closing SSH session: ' . $self->_connectStr());
  return;
}

sub copy {
  my ($self) = @_;
  my ($o_cmd, $key);
  
  unless($self->AccessList) {
    $self->Log->warning($self->CurrentUser . ' does not have shell access');
    print STDERR "You do not have shell access\n";
    return;
  }

  $key = $self->_getKeyFromAccessList();

  unless($key) {
    $self->Log->warning($self->CurrentUser . ' cannot access ' . $self->Host);
    print STDERR 'You do not have access to ' . $self->Host;
    print STDERR ' as ' . $self->RemoteUser . "\n";
    return;
  }

  if($self->Type eq 'rsync') {
    $self->Log->info('Opening RSYNC session: ' . $self->_connectStr());
    $self->Log->info('Copying ' . $self->From . ' to ' . $self->To);

    $o_cmd = new SSHJump::System::Call::Script::Rsync( {
      LogDir     => $self->Config->{'SCRIPT_LOG_DIR'},
      User       => $self->CurrentUser,
      Host       => $self->Host,
      RemoteUser => $self->RemoteUser,
      Key        => $key,
      From       => $self->From,
      To         => $self->To,
      Log        => $self->Log
    } );

  } else {
    $self->Log->info('Opening SCP session: ' . $self->_connectStr());
    $self->Log->info('Copying ' . $self->From . ' to ' . $self->To);

    $o_cmd = new SSHJump::System::Call::Script::SCP( {
      LogDir     => $self->Config->{'SCRIPT_LOG_DIR'},
      User       => $self->CurrentUser,
      Host       => $self->Host,
      RemoteUser => $self->RemoteUser,
      Key        => $key,
      From       => $self->From,
      To         => $self->To,
      Log        => $self->Log
    } );

  }

  $o_cmd->execute();

  if($o_cmd->ExitCode) {
    my $msg = 'Exited with status ' . $o_cmd->ExitCode;
    $self->Log->error($msg);
    print STDERR 'An error has occurred.  ' . $msg . "\n";
  }

  $self->Session->LogFile($o_cmd->FileBase . '.log');
  $self->Log->info('Closing copy session: ' . $self->_connectStr());
  return;
}

sub list {
  my ($self, $type, $search) = @_;

  $type = $type ? $type : '';
  $search = $search ? $search : '';

  if($type eq 'customer') {
    $self->_listByCustomer($search);
  } elsif($type eq 'group') {
    $self->_listByGroup($search);
  } else {
    $self->_listFull();
  }
}

sub execute {
  my ($self) = @_;
  my ($o_cmd, $key);

  unless($self->AccessList) {
    $self->Log->warning($self->CurrentUser . ' does not have shell access');
    print STDERR "You do not have shell access\n";
    return;
  }

  $key = $self->_getKeyFromAccessList();

  unless($key) {
    $self->Log->warning($self->CurrentUser . ' cannot access ' . $self->Host);
    print STDERR 'You do not have access to ' . $self->Host;
    print STDERR ' as ' . $self->RemoteUser . "\n";
    return;
  }

  $self->Log->info('Remote Command: ' . $self->RemoteCommand);

  $o_cmd = new SSHJump::System::Call::Script::RemoteCommand( {
    LogDir        => $self->Config->{'SCRIPT_LOG_DIR'},
    User          => $self->CurrentUser,
    Host          => $self->Host,
    RemoteUser    => $self->RemoteUser,
    Key           => $key,
    RemoteCommand => $self->RemoteCommand,
    Log           => $self->Log
  } );

  $o_cmd->execute();

  if($o_cmd->ExitCode) {
    my $msg = 'SSH exited with status ' . $o_cmd->ExitCode;
    $self->Log->error($msg);
    print STDERR 'An error has occurred.  ' . $msg . "\n";
  }

  $self->Session->LogFile($o_cmd->FileBase . '.log');
  $self->Log->info('End Remote Command Execution');
  return;
}

sub restart {
  my ($self) = @_;
  my ($o_cmd, $key);

  unless($self->AccessList) {
    $self->Log->warning($self->CurrentUser . ' does not have shell access');
    print STDERR "You do not have shell access\n";
    return;
  }

  $key = $self->_getKeyFromAccessList();

  unless($key) {
    $self->Log->warning($self->CurrentUser . ' cannot access ' . $self->Host);
    print STDERR 'You do not have access to ' . $self->Host;
    print STDERR ' as ' . $self->RemoteUser . "\n";
    return;
  }

  $self->Log->info('Service Restart: ' . $self->Service);

  $o_cmd = new SSHJump::System::Call::Script::Service( {
    LogDir     => $self->Config->{'SCRIPT_LOG_DIR'},
    User       => $self->CurrentUser,
    Host       => $self->Host,
    RemoteUser => $self->RemoteUser,
    Key        => $key,
    Service    => $self->Service,
    Log        => $self->Log
  } );

  $o_cmd->execute();

  if($o_cmd->ExitCode) {
    my $msg = 'SSH exited with status ' . $o_cmd->ExitCode;
    $self->Log->error($msg);
    print STDERR 'An error has occurred.  ' . $msg . "\n";
  }

  $self->Session->LogFile($o_cmd->FileBase . '.log');
  $self->Log->info('End Service Restart');
  return;
}

### Private Method Definitions #################################################
sub BUILD {
  my ($self) = @_;
  my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );
  my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );

  $self->{CurrentUser} = SSHJump::Utils::getCurrentUser();
  die "Cannot stat username...exiting\n" unless($self->CurrentUser);

  $user_obj->UserName($self->CurrentUser);
  $host_obj->HostName($self->Host);

  die "Cannot determine user's id...exiting\n"     unless($user_obj->UserID);
  die "Cannot determine host's id...exiting\n"     unless($host_obj->HostID);

  $self->{Session} = new SSHJump::DB::Session( {
    DBH => $self->DBH,
    Type => 'CMD',
    Reason => $self->Reason
  } );

  $self->Session->open();

  $self->{Log} = new SSHJump::DB::Log( {
    DBH       => $self->DBH,
    HostID    => $host_obj->HostID,
    UserID    => $user_obj->UserID,
    SessionID => $self->Session->SessionID,
    LogFile   => $self->Config->{'LOG_FILE'}
  } );

  # Initialize log object and check for errors...
  $self->Log->info('OPEN SESSION (CMD):  ' . $self->CurrentUser);
  die $self->Log->lastError . "\n" if(@{$self->Log->Errors});

  $self->_buildAccessList();
}

sub _buildAccessList {
  my ($self) = @_;
  my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );
  my $c_usergroup_obj = new SSHJump::DB::Collection::UserGroup( { DBH => $self->DBH } );
  my (@rv);

  # Auto populate objects...
  $user_obj->UserName($self->CurrentUser);
  $c_usergroup_obj->UserID($user_obj->UserID);

  return unless($c_usergroup_obj->Collection);

  foreach my $group (@{$c_usergroup_obj->Collection}) {
    my $c_hostgroup_obj = new SSHJump::DB::Collection::HostGroup( { DBH => $self->DBH } );
    my $sshkey_obj = new SSHJump::DB::SSHKey( { DBH => $self->DBH } );

    $c_hostgroup_obj->GroupID($group->GroupID);
    $sshkey_obj->SSHKeyID($group->SSHKeyID);

    next unless($c_hostgroup_obj->Collection);

    foreach my $host (@{$c_hostgroup_obj->Collection}) {
      push @rv, [ $group->GroupName,
                  $host->HostName,
                  $group->RemoteUser,
                  $sshkey_obj->Location,
                  $host->Customer,
                  $host->Aliases ];
    }
  }

  $self->{AccessList} = \@rv;
}

sub _getKeyFromAccessList {
  my ($self) = @_;
  my ($key);

  foreach my $record (@{$self->AccessList}) {
    if( ($record->[1] eq $self->Host) && 
        ($record->[2] eq $self->RemoteUser) ) {
      $key = $record->[3];
    }
  }

  return $key;
}

sub _connectStr {
  my ($self) = @_;
  return $self->RemoteUser . '@'. $self->Host;
}

sub _verifyHost {
  my ($self) = @_;
  my $o_host = new SSHJump::DB::Host( {
    DBH => $self->DBH,
    HostName => $self->Host
  } );

  # Lookup by either hostname or alias...
  $self->{'Host'} = $o_host->HostName;
}

sub _listFull {
  my ($self) = @_;

  print "\n";
  print sprintf( "%-16s%-48s%-16s", 'GROUP', 'SERVER', 'USER') . "\n";
  print '-' x 80 . "\n";

  unless($self->AccessList) {
    $self->Log->warning($self->CurrentUser . ' does not have shell access');
    print STDERR "You do not have shell access\n";
    return;
  }

  $self->Log->info('Listing user access for ' . $self->CurrentUser);

  foreach my $record (@{$self->AccessList}) {
    printf( "%-16s%-48s%-16s", @{$record});
    print "\n";
  }

  print '-' x 80 . "\n";
  print "\n";
}

sub _listByGroup {
  my ($self, $search) = @_;
  my ($buckets);

  foreach my $record (@{$self->AccessList}) {
    if($search) {
      next unless($record->[0] =~ m/$search/i);
    }

    unless(exists $buckets->{$record->[0]}) {
      $buckets->{$record->[0]} = [];
    }

    push @{$buckets->{$record->[0]}}, $record;
  } 

  foreach my $group (sort keys %{$buckets}) {
    print "\n";
    print '-' x 110 . "\n";
    print "GROUP:  " . $group . "\n";
    print "\n";
    print sprintf( "%-50s%-50s%-10s", 'ALIAS', 'SERVER', 'USER') . "\n";
    print '-' x 110 . "\n";
    print "\n";

    foreach my $record (@{$buckets->{$group}}) {
      if(@{$record->[5]} < 1) {
        printf( "%-50s%-50s%-10s", '[NA]', $record->[1], $record->[2]);
        print "\n";
      } else {
        for(my $i = 0; $i <  @{$record->[5]}; $i++) {
          printf( "%-50s%-50s%-10s", $record->[5]->[$i], $record->[1], $record->[2]);
          print "\n";
        }
      }
    }

    print "\n";
    print '-' x 110 . "\n";
  }
}

sub _listByCustomer {
  my ($self, $search) = @_;
  my ($buckets);

  foreach my $record (@{$self->AccessList}) {
    if($search) {
      next unless($record->[4] =~ m/$search/i);
    }

    unless(exists $buckets->{$record->[4]}) {
      $buckets->{$record->[4]} = [];
    }

    push @{$buckets->{$record->[4]}}, $record;
  } 

  foreach my $customer (sort keys %{$buckets}) {
    print "\n";
    print '-' x 110 . "\n";
    print "CUSTOMER:  " . $customer . "\n";
    print "\n";
    print sprintf( "%-50s%-50s%-10s", 'SERVER', 'ALIASES', 'USER') . "\n";
    print '-' x 110 . "\n";
    print "\n";

    foreach my $record (@{$buckets->{$customer}}) {
      if(@{$record->[5]} < 1) {
        printf( "%-50s%-50s%-10s", '[NA]', $record->[1], $record->[2]);
        print "\n";
      } else {
        for(my $i = 0; $i <  @{$record->[5]}; $i++) {
          printf( "%-50s%-50s%-10s", $record->[5]->[$i], $record->[1], $record->[2]);
          print "\n";
        }
      }
    }

    print "\n";
    print '-' x 110 . "\n";
  }
}

no Moose;

1;
