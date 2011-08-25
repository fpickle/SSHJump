package SSHJump::App::Handlers;

# This is a wrapper class for all of the dialog control handlers for SSHJump.
# Putting all these functions in one class should only be temporary...

use strict;
use Moose;

use SSHJump::Constants;
use SSHJump::Utils;

use SSHJump::DB::Group;
use SSHJump::DB::Host;
use SSHJump::DB::HostGroup;
use SSHJump::DB::Log;
use SSHJump::DB::Session;
use SSHJump::DB::SSHKey;
use SSHJump::DB::User;
use SSHJump::DB::UserGroup;

use SSHJump::DB::Collection::HostGroup;
use SSHJump::DB::Collection::UserGroup;

use SSHJump::System::Host;

use SSHJump::App::Actions;
use SSHJump::App::Control;

use SSHJump::App::Control::Main;
use SSHJump::App::Control::HostData;
use SSHJump::App::Control::HostGroup;
use SSHJump::App::Control::HostManagement;
use SSHJump::App::Control::HostOptions;
use SSHJump::App::Control::IPFilter;
use SSHJump::App::Control::IPFilterOptions;
use SSHJump::App::Control::GroupHost;
use SSHJump::App::Control::GroupManagement;
use SSHJump::App::Control::GroupOptions;
use SSHJump::App::Control::GroupUser;
use SSHJump::App::Control::LogSearch;
use SSHJump::App::Control::Permissions;
use SSHJump::App::Control::ProfileOptions;
use SSHJump::App::Control::RemoteAccess;
use SSHJump::App::Control::RemoveAlias;
use SSHJump::App::Control::ScriptChoice;
use SSHJump::App::Control::SessionHistory;
use SSHJump::App::Control::SSHKeyManagement;
use SSHJump::App::Control::SSHKeyRemoval;
use SSHJump::App::Control::SSHKeySelect;
use SSHJump::App::Control::UserGroup;
use SSHJump::App::Control::UserManagement;
use SSHJump::App::Control::UserOptions;
use SSHJump::App::Control::ViewAlias;
use SSHJump::App::Control::ViewStatus;

extends 'SSHJump::App';

### Class Properties ###########################################################
# Database Handle
has 'DBH' => ( is => 'rw', isa => 'Object', required => 1 );

# Function References
has 'EscapeHandler' => ( is => 'rw', isa => 'CodeRef' );
has 'ExitHandler'   => ( is => 'rw', isa => 'CodeRef' );

# String Properties
has 'CurrentUser' => ( is => 'rw', isa => 'Str', default => '', required => 1 );
has 'Host'        => ( is => 'rw', isa => 'Str', default => '' );

# Configuration HashRef
has 'Config'       => ( is => 'rw', isa => 'HashRef', required => 1);
has 'ControlParms' => ( is => 'ro', isa => 'HashRef' );

# Object Properties
has 'Actions'  => (is => 'ro', isa => 'Actions');
has 'Log'      => (is => 'ro', isa => 'Log');
has 'Session'  => (is => 'ro', isa => 'Session');

### Specialized Method Declarations ############################################
sub groupHostCheckList;
sub groupManagementMenu;
sub groupOptionsMenu;
sub groupUserCheckList;
sub guiPermissionsMenu;
sub hostDataForm;
sub hostGroupCheckList;
sub hostManagementMenu;
sub hostOptionsMenu;
sub ipFilterEdit;
sub ipFilterOptionsMenu;
sub logSearch;
sub mainMenu;
sub profileOptionsMenu;
sub remoteAccessMenu;
sub removeAliasMenu;
sub scriptChoiceMenu;
sub sessionHistory;
sub sshKeyManagement;
sub sshKeySelect;
sub userDataForm;
sub userGroupCheckList;
sub userManagementMenu;
sub userOptionsMenu;
sub viewHostAliases;
sub viewUserStatus;

### Generic Method Declarations ################################################
sub audit;

### Specialized Method Definitions #############################################
sub groupHostCheckList {
	my ($self, $group) = @_;
	my ($hosts, @hosts, @remote_users);
	my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );
	my $c_grouphost_obj = new SSHJump::DB::Collection::HostGroup( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::GroupHost($self->ControlParms);
	my $message = new SSHJump::App::Control::Message($self->ControlParms);

	# Should auto populate...
	$group_obj->GroupName($group);
	$c_grouphost_obj->GroupID($group_obj->GroupID);

	$control->Group($group);

	if($control->Empty) {
		$message->Title('WARNING');
		$message->appendText('There are no active hosts defined.  You ');
		$message->appendText('must either add a host to the system or ');
		$message->appendText('unlock an existing host before you can ' );
		$message->appendText('use this option.' . "\n"                 ); 
		$message->Height(7);
		$message->show();       

		$self->Log->warning("Cannot continue because no hosts are defined");
		return;                         
	}

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$hosts = $control->Data;

	$hosts =~ s/"//g;
	@hosts = split(/\s/, $hosts);

	# Before we insert the records, clean out the old entries...
	$c_grouphost_obj->clean();

	foreach my $host (@hosts) {
		my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );
		my $hostgroup_obj = new SSHJump::DB::HostGroup( { DBH => $self->DBH } );

		# Should auto populate...
		$host_obj->HostName($host);

		$hostgroup_obj->GroupID($group_obj->GroupID);
		$hostgroup_obj->HostID($host_obj->HostID);

		unless($hostgroup_obj->addHostGroup()) {
			my $last_error = $hostgroup_obj->lastError;

			$message->Title('ERROR');
			$message->appendText( 'A fatal error has occured.' . "\n"   );
			$message->appendText( 'The host was not added.' . "\n"      );
			$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );

			$message->show();

			$self->Log->error("Error adding $host to $group:  $last_error");
			return;
		}
	}

	# Confirm host to group addition...
	$message->Title('Change Complete');
	$message->appendText( 'The host list for group \Zb\Z4'        );
	$message->appendText( $group . '\Zn has been modified.' . "\n");
	$message->Height(7);

	$message->show();

	$self->Log->info("Hosts added to group $group");
	return;
}

sub groupManagementMenu {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::GroupManagement($self->ControlParms);

		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^ADD$/)  { $self->Actions->addGroup(); next; }
		if($selection =~ m/^BACK$/) {                             last; }
		$self->groupOptionsMenu($selection);
	}
}

sub groupOptionsMenu {
	my ($self, $group) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::GroupOptions($self->ControlParms);

		$control->Group($group);
		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^REMOVE$/) { $self->Actions->delGroup($group);  last; }
		if($selection =~ m/^HOSTS$/)  { $self->groupHostCheckList($group); next; }
		if($selection =~ m/^USERS$/)  { $self->groupUserCheckList($group); next; }
		#if($selection =~ m/^VIEW$/)   { next; }
		if($selection =~ m/^BACK$/)   {                                    last; }
	}
}

sub groupUserCheckList {
	my ($self, $group) = @_;
	my ($users, @users);
	my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );
	my $c_usergroup_obj = new SSHJump::DB::Collection::UserGroup( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::GroupUser($self->ControlParms);
	my $message = new SSHJump::App::Control::Message($self->ControlParms);

	# Should auto populate...
	$group_obj->GroupName($group);
	$c_usergroup_obj->GroupID($group_obj->GroupID);

	$control->Group($group);

  if($control->Empty) {
		$message->Title('WARNING');
		$message->appendText('There are no active users defined.  You ');
		$message->appendText('must either add a user to the system or ');
		$message->appendText('unlock an existing user before you can ' );
		$message->appendText('use this option.' . "\n"                 ); 
		$message->Height(7);
		$message->show();

		$self->Log->warning("Cannot continue because no users are defined");
		return;
	}

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$users = $control->Data;

	$users =~ s/"//g;
	@users = split(/\s/, $users);

	# Before we insert the records, clean out the old entries...
	$c_usergroup_obj->clean();

	foreach my $user (@users) {
		my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );
		my $usergroup_obj = new SSHJump::DB::UserGroup( { DBH => $self->DBH } );

		# Should auto populate...
		$user_obj->UserName($user);

		$usergroup_obj->GroupID($group_obj->GroupID);
		$usergroup_obj->UserID($user_obj->UserID);

		unless($usergroup_obj->addUserGroup()) {
			my $last_error = $usergroup_obj->lastError;

			$message->Title('ERROR');
			$message->appendText( 'A fatal error has occured.' . "\n"   );
			$message->appendText( 'The user was not added.' . "\n"      );
			$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );

			$message->show();

			$self->Log->error("Error adding $user to $group:  $last_error");
			return;
		}
	}

	# Confirm user to group addition...
	$message->Title('Change Complete');
	$message->appendText('The user list for group \Zb\Z4'        );
	$message->appendText($group . '\Zn has been modified.' . "\n");
	$message->Height(7);
	$message->show();

	$self->Log->info("Users added to $group access list\n");
	return;
}

sub guiPermissionsMenu {
	my ($self, $user) = @_;
	my $control = new SSHJump::App::Control::Permissions($self->ControlParms);
	my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message($self->ControlParms);
	my ($perm, $msg);

	$control->User($user);
	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$perm = $control->Data;

	return unless($user_obj && $perm);

	$user_obj->UserName($user);
	$user_obj->Access($perm);

	unless($user_obj->updateUser()) {
		my $last_error = $user_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );

		$message->show();

		$self->Log->error("Error updating account $user:  $last_error");
		return;
	}

	$message->Title('Change Complete');
	$message->Text('Successfully updated account \Zb\Z4' . $user . '\Zn.');
	$message->Height(5);
	$message->show();

	$self->Log->info("Account permissions for $user have been updated");
	return;
}

sub hostDataForm {
	my ($self) = @_;
	my ($hostname, $customer, $aliases, $host_obj, @aliases);
	my $control = new SSHJump::App::Control::HostData($self->ControlParms);
	my $message = new SSHJump::App::Control::Message($self->ControlParms);

	$control->show();
	return if($control->ExitMsg eq 'ESC');
	return if($control->ExitMsg eq 'NO/CANCEL');

	($hostname, $customer, $aliases) = @{$control->Data};

	return unless($hostname);
	return unless($customer);
	return if($customer =~ m/^locked$/i);
	return unless($self->inputCheck($hostname, 'Hostname', 'host'));
	return unless($self->inputCheck($customer, 'Customer', 'alpha_numeric_space'));

	# Add the host...
	$host_obj = new SSHJump::System::Host( { DBH => $self->DBH } );

	$host_obj->HostName($hostname);
	$host_obj->Customer($customer) if($customer);

  if($self->Config->{'ENABLE_DNS_CHECK'} == 1) {
	  unless($host_obj->resolves()) {
		  $message->Title('ERROR');
		  $message->appendText( 'A fatal error has occured.' . "\n"                   );
		  $message->appendText( 'The host was not added.' . "\n"                      );
		  $message->appendText( '\Zb\Z4Could not resolve ' . $hostname . '\Zn' . "\n" );

		  $message->show();

		  $self->Log->error("Error adding $hostname:  Could not resolve host");
		  return;
    }
	}

	unless($host_obj->addHost()) {
		my $last_error = $host_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The host was not added.' . "\n"      );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );

		$message->show();

		$self->Log->error("Error adding $hostname:  $last_error");
		return;
	}

	$aliases =~ s/\s//g;
	@aliases = split(/,/, $aliases);

	foreach my $alias (@aliases) {
		next unless($self->inputCheck($alias, 'Alias', 'host'));
		$host_obj->addAlias($alias);
	}

	# Confirm host addition...
	$message->Title('Change Complete');
	$message->Text('Host \Zb\Z4'. $hostname . '\Zn has been added.' . "\n");
	$message->Height(6);
	$message->show();

	$self->Log->info("Host $hostname added");
	return;
}

sub hostGroupCheckList {
	my ($self, $host) = @_;
	my $c_hostgroup_obj = new SSHJump::DB::Collection::HostGroup( { DBH => $self->DBH } );
	my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::HostGroup($self->ControlParms);
	my $message = new SSHJump::App::Control::Message($self->ControlParms);
	my ($groups, @groups, $msg);

	# Should auto populate...
	$host_obj->HostName($host);
	$c_hostgroup_obj->HostID($host_obj->HostID);

	$control->Host($host);

	if($control->Empty) {
		$message->Title('WARNING');
		$message->appendText('There are no groups defined.  You '    );
		$message->appendText('must add a group to the system before ');
		$message->appendText('you can use this option.' . "\n"       );
		$message->Height(7);
		$message->show();

		$self->Log->warning("Cannot continue because no groups are defined");
		return;
	}

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$groups = $control->Data;

	# Before we insert the records, clean out the old entries...
	$c_hostgroup_obj->clean();

	if($groups) {
		$groups =~ s/"//g;
		@groups = split(/\s/, $groups);

		foreach my $group (@groups) {
			my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );
			my $hostgroup_obj = new SSHJump::DB::HostGroup( { DBH => $self->DBH } );

			# Should auto populate...
			$group_obj->GroupName($group);

			$hostgroup_obj->GroupID($group_obj->GroupID);
			$hostgroup_obj->HostID($host_obj->HostID);

			unless($hostgroup_obj->addHostGroup()) {
				my $last_error = $hostgroup_obj->lastError;

				$message->Title('ERROR');
				$message->appendText( 'A fatal error has occured.' . "\n"    );
				$message->appendText( 'The host/group was not added.' . "\n" );
				$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n"  );

				$message->show();

				$self->Log->error("Error adding $host to $group:  $last_error");
				return;
			}
		}
	}

	# Confirm host to group addition...
	$message->Title('Change Complete');
	$message->Text('Host \Zb\Z4' . $host . '\Zn groups have been modified.');
	$message->Height(7);
	$message->show();

	$self->Log->info("Groups modified for $host");
	return;
}

sub hostManagementMenu {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::HostManagement($self->ControlParms);

		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^ADD$/)  { $self->hostDataForm(); next; }
		if($selection =~ m/^BACK$/) {                        last; }
		$self->hostOptionsMenu($selection);
	}
}

sub hostOptionsMenu {
	my ($self, $host) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::HostOptions($self->ControlParms);

		$control->Host($host);
		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^REMOVE$/) { $self->Actions->delHost($host);        last; }
		if($selection =~ m/^UPDATE$/) { $self->Actions->modifyHostData($host); next; }
		if($selection =~ m/^DALIAS$/) { $self->removeAliasMenu($host);         next; }
		if($selection =~ m/^ALIAS$/)  { $self->Actions->addAliases($host);     next; }
		if($selection =~ m/^VIEW$/)   { $self->viewHostAliases($host);         next; }
		if($selection =~ m/^GROUPS$/) { $self->hostGroupCheckList($host);      next; }
		if($selection =~ m/^UNLOCK$/) { $self->Actions->unlockHost($host);     next; }
		if($selection =~ m/^LOCK$/)   { $self->Actions->lockHost($host);       next; }
		if($selection =~ m/^BACK$/)   {                                        last; }
	}
}

sub ipFilterEdit {
	my ($self, $file) = @_;
	my %conf_hashref = %{$self->ControlParms};
	$conf_hashref{'File'} = $file;

	my $control = new SSHJump::App::Control::IPFilter(\%conf_hashref);
	my $message = new SSHJump::App::Control::Message($self->ControlParms);

	$control->show();

	my @file = @{$control->Data};
	my $path = $self->Config->{'HOSTS_TMP_DIR'};
	my ($msg);

	SSHJump::Utils::prepareDirectory($path);

	return 0 unless(open(FILE, '>' . $path . '/' . $file));

	foreach my $line (@file) {
		print FILE $line . "\n";
	}

	close(FILE);

	$message->Title('Complete');
	$message->appendText( 'File change complete.  It may take a few '        );
	$message->appendText( 'minutes for cron to install the new file.' . "\n" );
	$message->Height(7);
	$message->show();

	$self->Log->info($file . ' file updated');
	return 1;
}

sub ipFilterOptionsMenu {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::IPFilterOptions($self->ControlParms);

		$control->show();

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^ALLOW$/) { $self->ipFilterEdit('hosts.allow'); next; }
		if($selection =~ m/^DENY$/)  { $self->ipFilterEdit('hosts.deny');  next; }
		if($selection =~ m/^BACK$/)  {                                     last; }
	}
}

sub logSearch {
	my ($self) = @_;
	my $control = new SSHJump::App::Control::LogSearch($self->ControlParms);
	my ($selection);

	$control->show();
	$selection = $control->Data;
	return if($control->ExitMsg eq 'NO/CANCEL');

	$self->scriptChoiceMenu($selection);
	return;
}

sub mainMenu {
	my ($self) = @_;
	my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::Main($self->ControlParms);
	my ($selection);

	$user_obj->UserName($self->CurrentUser);

	if($user_obj->Active eq 'N') {
		$control->Access('LOCKED');
	} else {
		$control->Access($user_obj->Access);
	}

	while(1) {
		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		$selection =  $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^USERS$/)   { $self->userManagementMenu();  next; }
		if($selection =~ m/^HOSTS$/)   { $self->hostManagementMenu();  next; }
		if($selection =~ m/^GROUPS$/)  { $self->groupManagementMenu(); next; }
		if($selection =~ m/^PROFILE$/) { $self->profileOptionsMenu();  next; }
		if($selection =~ m/^SHELL$/)   { $self->remoteAccessMenu();    next; }
		if($selection =~ m/^FILTER$/)  { $self->ipFilterOptionsMenu(); next; }
		if($selection =~ m/^KEYS$/)    { $self->sshKeyManagement();    next; }
		if($selection =~ m/^STATUS$/)  { $self->viewUserStatus();      next; }
		if($selection =~ m/^LOGS$/)    { $self->logSearch();           next; }
		if($selection =~ m/^EXIT$/)    {                               last; }

		# /HIST/       and do { view_hist; last; };
		# /STATUS/     and do { user_status; last; };
	}

	$self->Session->close();
}

sub profileOptionsMenu {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::ProfileOptions($self->ControlParms);

		$control->show();

		my $selection = $control->Data;
		return if($control->ExitMsg eq 'NO/CANCEL');
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^PASS$/) { $self->Actions->passwordChange(); next; }
		if($selection =~ m/^DATA$/) { $self->userDataForm();            next; }
		if($selection =~ m/^BACK$/) {                                   last; }
	}
}

sub remoteAccessMenu {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::RemoteAccess($self->ControlParms);

		$control->show();

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^BACK$/)  { last; }
		$self->Actions->sshConnect($selection);
	}
}

sub removeAliasMenu {
	my ($self, $host) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::RemoveAlias($self->ControlParms);

		$control->Host($host);
		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		last if($selection =~ m/^BACK$/);
		$self->Actions->delAlias($host, $selection);
	}
}

sub scriptChoiceMenu {
	my ($self, $form_data) = @_;
	my ($user, $host, $file, $start, $end) = @{$form_data};
	my %obj_config = %{$self->ControlParms};

	$obj_config{'User'}      = $user;
	$obj_config{'Host'}      = $host;
	$obj_config{'LogFile'}   = $file;
	$obj_config{'StartDate'} = $start;
	$obj_config{'EndDate'}   = $end;

	while(1) {
		my $control = new SSHJump::App::Control::ScriptChoice(\%obj_config);
		$control->show();

		my $selection = $control->Data;
		return if($control->ExitMsg eq 'NO/CANCEL');
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		last if($selection =~ m/^BACK$/);
		$self->Actions->scriptPlayback($selection);
	}
}

sub sessionHistory {
	my ($self, $user_session) = @_;
	my %conf_hashref = %{$self->ControlParms};
	my ($session_id);

	while(1) {
		if($user_session =~ m/^\w+\[(\d+)\]$/) {
			$session_id = $1;
		} else {
			return;
		}

		$conf_hashref{'SessionID'} = $session_id;

		my $control = new SSHJump::App::Control::SessionHistory(\%conf_hashref);
		
		$control->show();

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^BACK$/) { last; }
		#$self->sessionHistory($selection);
	}
}

sub sshKeyManagement {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::SSHKeyManagement($self->ControlParms);

		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^REG$/)  { $self->sshKeySelect();    next; }
		if($selection =~ m/^GEN$/)  { $self->Actions->genKey(); next; }
		if($selection =~ m/^DREG$/) { $self->sshKeyRemoval();   next; }
		if($selection =~ m/^BACK$/) {                           last; }
	}
}

sub sshKeyRemoval {
	my ($self) = @_;
	my $control = new SSHJump::App::Control::SSHKeyRemoval($self->ControlParms);
	my $message = new SSHJump::App::Control::Message($self->ControlParms);
	my ($keys, @keys);

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$keys = $control->Data;
	$keys =~ s/"//g;
	@keys = split(/\s/, $keys);

	foreach my $key (@keys) {
		my $o_key = new SSHJump::DB::SSHKey( { DBH => $self->DBH } );
		$o_key->Location($key);

		unless($o_key->delKey()) {
			my $last_error = $o_key->lastError;

			$message->Title('ERROR');
			$message->Text( 'A fatal error has occured.' . "\n" );
			$message->appendText( 'Key was not removed.' . "\n" );
			$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
			$message->show();

			$self->Log->error("Error removing key $key:  $last_error");
			return;
		}

		$self->Log->info("Key $key removed");
	}

	$message->Title('Change Complete');
	$message->Text( 'Selected keys have been removed.' );
	$message->Height(5);
	$message->show();
}

sub sshKeySelect {
	my ($self) = @_;
	my $key_obj = new SSHJump::DB::SSHKey( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::SSHKeySelect($self->ControlParms);

	$control->Directory($self->Config->{'SSH_KEY_DIR'});
	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	my $key_path = $control->Data;
	my $message = new SSHJump::App::Control::Message($self->ControlParms);

	return unless($key_path);
	return unless($self->inputCheck($key_path, 'Location', 'path'));
	return if( -d $key_path );

	$key_obj->Location($key_path);

	if($key_obj->SSHKeyID) {
		$message->Title('WARNING');
		$message->Text( 'Key has already been registered:' . "\n" );
		$message->appendText( '\Zb\Z4' . $key_path . '\Zn'     );
		$message->Height(7);
		$message->show();

		$self->Log->warning("Key $key_path already registered");
		return;
	}

	unless($key_obj->addKey()) {
		my $last_error = $key_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The key was not added.' . "\n"       );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error adding key $key_path:  $last_error");
		return;
	}

	# Confirm key addition...
	$message->Title('Change Complete');
	$message->Text( 'Key has been registered:' . "\n" );
	$message->appendText( '\Zb\Z4' . $key_path . '\Zn' );
	$message->Height(7);
	$message->show();

	$self->Log->info("Key $key_path added");
	return;
}

sub userDataForm {
	my ($self, $user) = @_;
	my ($user_obj);

	$user = $self->CurrentUser unless($user);

	$user_obj = new SSHJump::DB::User( { DBH      => $self->DBH,
	                                     UserName => $user } );

	# Add user if user record does not exist...
	if(!$user_obj->UserID || $user eq 'NEW' ) {
		$self->Actions->addUser();
	} else {
		$self->Actions->modifyUserData($user);
	}

	return;
}

sub userGroupCheckList {
	my ($self, $user) = @_;
	my ($groups, @groups);
	my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );
	my $c_usergroup_obj = new SSHJump::DB::Collection::UserGroup( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::UserGroup($self->ControlParms);
	my $message = new SSHJump::App::Control::Message($self->ControlParms);

	# Should auto populate...
	$user_obj->UserName($user);
	$c_usergroup_obj->UserID($user_obj->UserID);

	$control->User($user);

	if($control->Empty) {
		$message->Title('WARNING');
		$message->appendText('There are no groups defined.  You '    );
		$message->appendText('must add a group to the system before ');
		$message->appendText('you can use this option.' . "\n"       );
		$message->Height(7);
		$message->show();

		$self->Log->warning("Cannot continue because no groups are defined");
		return;
	}

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$groups = $control->Data;
	$groups =~ s/"//g;
	@groups = split(/\s/, $groups);

	# Before we insert the records, clean out the old entries...
	$c_usergroup_obj->clean();

	foreach my $group (@groups) {
		my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );
		my $usergroup_obj = new SSHJump::DB::UserGroup( { DBH => $self->DBH } );

		# Should auto populate...
		$group_obj->GroupName($group);

		$usergroup_obj->GroupID($group_obj->GroupID);
		$usergroup_obj->UserID($user_obj->UserID);

		unless($usergroup_obj->addUserGroup()) {
			my $last_error = $usergroup_obj->lastError;

			$message->Title('ERROR');
			$message->appendText( 'A fatal error has occured.' . "\n"   );
			$message->appendText( 'The host was not added.' . "\n"      );
			$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
			$message->show();

			$self->Log->error("Error adding $group to $user:  $last_error");
			return;
		}
	}

	# Confirm user to group addition...
	$message->Title('Change Complete');
	$message->appendText('Group access for account \Zb\Z4' . $user);
	$message->appendText('\Zn has been updated.' . "\n"           );
	$message->Height(7);
	$message->show();

	$self->Log->info("Groups modified for user $user");
	return;
}

sub userManagementMenu {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::UserManagement($self->ControlParms);

		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^ADD$/) { $self->userDataForm('NEW'); next; }
		if($selection =~ m/^BACK$/) {                            last; }
		$self->userOptionsMenu($selection);
	}
}

sub userOptionsMenu {
	my ($self, $user) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::UserOptions($self->ControlParms);

		$control->User($user);
		$control->show();
		return if($control->ExitMsg eq 'NO/CANCEL');

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^FORCE$/) {
			$self->Actions->forcePasswordChange($user);
			next;
		}

		if($selection =~ m/^REMOVE$/) { $self->Actions->delUser($user);    last; }
		if($selection =~ m/^UNLOCK$/) { $self->Actions->unlockUser($user); next; }
		if($selection =~ m/^LOCK$/)   { $self->Actions->lockUser($user);   next; }
		if($selection =~ m/^DATA$/)   { $self->userDataForm($user);        next; }
		if($selection =~ m/^PERMS$/)  { $self->guiPermissionsMenu($user);  next; }
		if($selection =~ m/^GROUPS$/) { $self->userGroupCheckList($user);  next; }
		if($selection =~ m/^BACK$/)   {                                    last; }
	}
}

sub viewHostAliases {
	my ($self, $host) = @_;
	my $control = new SSHJump::App::Control::ViewAlias($self->ControlParms);

	$control->Host($host);
	$control->show();

	return;
}

sub viewUserStatus {
	my ($self) = @_;

	while(1) {
		my $control = new SSHJump::App::Control::ViewStatus($self->ControlParms);
		
		$control->show();

		my $selection = $control->Data;
		return unless($selection);

		$self->audit($selection, (caller(0))[3]);

		if($selection =~ m/^BACK$/) { last; }
		$self->sessionHistory($selection);
	}
}

### Generic Method Definitions #################################################
sub audit {
	my ($self, $selection, $caller) = @_;
	my $log_entry  = '[' . $caller . '] ' . $self->CurrentUser;
	   $log_entry .= ' has selected ' . $selection;

	$self->Log->info($log_entry);
}

### Private Methods ############################################################
sub BUILD {
	my ($self) = @_;
	my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );
	my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );

	$self->CurrentUser(SSHJump::Utils::getCurrentUser);
	die "Cannot stat username...exiting\n" unless($self->CurrentUser);

	$user_obj->UserName($self->CurrentUser);
	$host_obj->HostName($self->Host);

	die "Cannot determine user's access...exiting\n" unless($user_obj->Access);
	die "Cannot determine user's id...exiting\n"     unless($user_obj->UserID);
	die "Cannot determine host's id...exiting\n"     unless($host_obj->HostID);

	$self->{Session} = new SSHJump::DB::Session( {
		DBH => $self->DBH,
		Type => 'APP',
		Reason => 'Administration'
 	} );

	$self->Session->open();

	$self->{Log} = new SSHJump::DB::Log( {
		DBH           => $self->DBH,
		SessionID     => $self->Session->SessionID,
		HostID        => $host_obj->HostID,
		UserID        => $user_obj->UserID,
		LogFile       => $self->Config->{'LOG_FILE'}
	} );

	$self->{Actions} = new SSHJump::App::Actions( {
		DBH           => $self->DBH,
		Log           => $self->Log,
		CurrentUser   => $self->CurrentUser,
		Config        => $self->Config
	} );

	$self->{ControlParms} = {
		DBH           => $self->DBH,
		EscapeHandler => $self->EscapeHandler,
		ExitHandler   => $self->ExitHandler,
		Config        => $self->Config
	};

	# Initialize log object and check for errors...
	$self->Log->info('OPEN SESSION (APP):  ' . $self->CurrentUser);
	$self->Log->info($self->CurrentUser . ': access level ' . $user_obj->Access);
	die $self->Log->lastError . "\n" if(@{$self->Log->Errors});
}

no Moose;

1;
