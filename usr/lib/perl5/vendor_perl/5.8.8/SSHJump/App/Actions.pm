package SSHJump::App::Actions;

# This is a wrapper class for all of the dialog control actions for SSHJump.
# Putting all these functions in one class should only be temporary...

use strict;
use Moose;
use File::Basename;

use SSHJump::Utils;
use SSHJump::Constants;

use SSHJump::App::Control::Input;
use SSHJump::App::Control::GroupData;
use SSHJump::App::Control::Message;
use SSHJump::App::Control::Password;
use SSHJump::App::Control::Permissions;
use SSHJump::App::Control::SSHKeyRadio;
use SSHJump::App::Control::UserData;

use SSHJump::System::User;
use SSHJump::System::Call::SshKeygen;

extends 'SSHJump::App';

### Class Properties ###########################################################
# Object Properties
has 'Log'      => (is => 'rw', isa => 'Log', required => 1);

# String Properties
has 'CurrentUser' => ( is => 'rw', isa => 'Str', default => '', required => 1 );

# Database Handle
has 'DBH' => ( is => 'rw', isa => 'Object', required => 1 );

# Configuration HashRef
has 'Config' => ( is => 'rw', isa => 'HashRef', required => 1 );

### Specialized Method Declarations ############################################
sub addAliases;
sub addGroup;
sub addUser;
sub delAlias;
sub delGroup;
sub delHost;
sub delUser;
sub forcePasswordChange;
sub genKey;
sub lockHost;
sub lockUser;
sub modifyHostData;
sub modifyUserData;
sub passwordChange;
sub scriptPlayback;
sub sshConnect;
sub unlockHost;
sub unlockUser;

### Generic Method Declarations ################################################

### Specialized Method Definitions #############################################
sub addAliases {
	my ($self, $host) = @_;
	my ($aliases, @aliases, @additions);
	my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my $control = new SSHJump::App::Control::Input( { Config => $self->Config } );

	$control->Title('Add Host Aliases');
	$control->appendText('List all \Zb\Z4' . $host . '\Zn aliases ');
	$control->appendText('(comma separated):'  );
	$control->CancelButton(1);

	$control->show();
	return if($control->ExitMsg eq 'ESC');
	return if($control->ExitMsg eq 'NO/CANCEL');

	$aliases = $control->Data;
	return unless($aliases);

	$aliases =~ s/\s//g;
	@aliases = split(/,/, $aliases);

	$host_obj->HostName($host);

	foreach my $alias (@aliases) {
		next unless($self->inputCheck($alias, 'Alias', 'host'));

		unless($host_obj->addAlias($alias)) {
			my $last_error = $host_obj->lastError;

			$message->Title('ERROR');
			$message->appendText( 'A fatal error has occured.' . "\n"   );
			$message->appendText( 'The alias was not added.' . "\n"     );
			$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
			$message->show();

			$self->Log->error("Error adding alias $alias for $host:  $last_error");
			return;
		}

		push @additions, $alias;
		$self->Log->info("Alias $alias added for $host");
	}

	if(@additions) {
		$message->Title('Alias Additions');

		# Confirm aliases addition...
		if(@additions > 1) {
			$message->Text( 'Aliases \Zb\Z4' . join(',', @additions) . '\Zn have' );
		} else {
			$message->Text( 'Alias \Zb\Z4' . "@additions" . '\Zn has' );
		}

		$message->appendText( ' been added to host' .  "\n");
		$message->appendText( '\Zb\Z4' . $host . '\Zn' . "\n" );
		$message->Height(7);
		$message->show();
	}

	return;
}

sub addGroup {
	my ($self) = @_;
	my ($group, $description, $remote_user, $key_location);
	my $key_obj = new SSHJump::DB::SSHKey( { DBH => $self->DBH } );
	my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::GroupData( { Config => $self->Config } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	system("clear");

	$control->show();
	return if($control->ExitMsg eq 'ESC');
	return if($control->ExitMsg eq 'NO/CANCEL');

	($group, $description, $remote_user) = @{$control->Data};

	return unless($group && $remote_user);
	return unless($self->inputCheck($group, 'Group Name', 'alpha_numeric'));
	return unless($self->inputCheck($description, 'Description', 'alpha_numeric_space'));
	return unless($self->inputCheck($remote_user, 'Remote User', 'alpha_numeric'));

	$control = new SSHJump::App::Control::SSHKeyRadio( {
		DBH    => $self->DBH,
		Config => $self->Config
	} );

	$control->User($remote_user);
	$control->Group($group);
	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$key_location = $control->Data;
	return unless($key_location);

	$key_obj->Location($key_location);

	# Add the group...
	$group_obj->GroupName($group);
	$group_obj->Description($description);
	$group_obj->RemoteUser($remote_user);
	$group_obj->SSHKeyID($key_obj->SSHKeyID);

	unless($group_obj->addGroup()) {
		my $last_error = $group_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The group was not added.' . "\n"     );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error adding $group:  $last_error");
		return;
	}

	# Confirm group addition...
	$message->Title('Change Complete');
	$message->Text('Group \Zb\Z4'. $group. '\Zn has been added.' . "\n");
	$message->Height(6);
	$message->show();

	$self->Log->info("Group $group added");
	return;
}

sub addUser {
	my ($self) = @_;
	my ($username, $password, $real_name, $email);
	my ($phone, $access, $user_obj);
	my $control = new SSHJump::App::Control::UserData( {
		DBH    => $self->DBH,
		Config => $self->Config
	} );

	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my $permissions = new SSHJump::App::Control::Permissions( { Config => $self->Config } );

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	system("clear");

	( $username,
	  $password,
	  $real_name,
	  $email,
	  $phone ) = @{$control->Data};
	return unless($username && $password);
	return unless($self->inputCheck($username, 'Username', 'alpha_numeric'));
	return unless($self->inputCheck($password, 'Password', 'password'));
	return unless($self->inputCheck($real_name, 'Real Name', 'alpha_numeric_space'));
	return unless($self->inputCheck($email, 'Email', 'email'));
	return unless($self->inputCheck($phone, 'Phone', 'phone'));

	system("clear");
	
	$permissions->User($username);
	$permissions->show();

	$access = $permissions->Data;
	return unless($access);

	$user_obj = new SSHJump::System::User( { DBH => $self->DBH } );

	$user_obj->UserName($username);
	$user_obj->Password($password);
	$user_obj->RealName($real_name);
	$user_obj->Email($email);
	$user_obj->Phone($phone);
	$user_obj->Access($access);

	unless($user_obj->addUser()) {
		my $last_error = $user_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The user was not added.' . "\n"      );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error adding user $username:  $last_error");
		return;
	}

	# Confirm user addition...
	$message->Title('Change Complete');
	$message->Text('The user \Zb\Z4'. $username . '\Zn has been added.');
	$message->Height(6);
	$message->show();

	$self->Log->info("User $username added to the system");
	return;
}

sub delAlias {
	my ($self, $host, $alias) = @_;
	my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	$host_obj->HostName($host);

	unless($host_obj->delAlias($alias)) {
		my $last_error = $host_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The alias was not removed.' . "\n"   );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error removing alias $alias from $host:  $last_error");
		return;
	}

	# Confirm alias deletion...
	$message->Title('Change Complete');
	$message->appendText( 'Host \Zb\Z4' . $host . '\Zn alias '        );
	$message->appendText( '\Zb\Z4' . $alias . '\Zn has been removed.' );
	$message->Height(7);
	$message->show();

	$self->Log->info("Alias $alias removed from $host");
	return;
}

sub delGroup {
	my ($self, $group) = @_;
	my ($sure, $group_obj);
	my $control = new SSHJump::App::Control::Input( { Config => $self->Config } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	system("clear");

	$control->Title('WARNING');
	$control->appendText( '\Zb\Z4GROUP ' . $group . ' WILL BE COMPLETELY'    );
	$control->appendText( ' REMOVED FROM THE SYSTEM\Zn' . "\n\n" . 'Type '   );
	$control->appendText( '\Zb\Z2YES\Zn in all caps if you are sure.' . "\n" );
	$control->CancelButton(1);
	$control->Height(12);
	$control->Width(60);

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$sure = $control->Data;
	return unless($sure);

	if($sure ne 'YES') {
		$message->Title('Action Cancelled');
		$message->Text('Group \Zb\Z4' . $group . ' \Znwas not removed.');
		$message->show();

		return;
	}

	$group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );
	$group_obj->GroupName($group);

	unless($group_obj->delGroup()) {
		my $last_error = $group_obj->lastError;


		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The group was not removed.' . "\n"   );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error removing group $group:  $last_error");
		return;
	}

	$message->Title('Group Removed');
	$message->Text('Group \Zb\Z4' . $group . '\Zn has been removed.');
	$message->Height(6);
	$message->show();

	$self->Log->info("Group $group removed");
	return;
}

sub delHost {
	my ($self, $host) = @_;
	my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::Input( { Config => $self->Config } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my ($sure);

	system("clear");

	$control->Title('WARNING');
	$control->appendText( '\Zb\Z4HOST ' . $host . ' WILL BE COMPLETELY REMOVED' );
	$control->appendText( ' FROM THE SYSTEM\Zn' . "\n" . 'Type \Zb\Z2YES\Zn'    );
	$control->appendText( ' in all caps if you are sure.' . "\n"                );
	$control->CancelButton(1);

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$sure = $control->Data;
	return unless($sure);

	if($sure ne 'YES') {
		$message->Title('Action Cancelled');
		$message->Text('Host \Zb\Z4' . $host . ' \Zn was not removed.' . "\n");
		$message->show();
		return;
	}

	$host_obj->HostName($host);

	unless($host_obj->delHost()) {
		my $last_error = $host_obj->lastError;

		$message->Title('ERROR');
		$message->appendText('A fatal error has occured.\nThe host was not removed.' );
		$message->appendText( "\n" . '\Zb\Z4' . $last_error . '\Zn' . "\n"           );
		$message->show();

		$self->Log->error("Error removing host $host:  $last_error");
		return;
	}

	$message->Title('Change Complete');
	$message->Text('Host \Zb\Z4' . $host . '\Zn has been removed.' . "\n" );
	$message->Height(6);
	$message->show();

	$self->Log->info("Host $host removed");
	return;
}

sub delUser {
	my ($self, $user) = @_;
	my $user_obj = new SSHJump::System::User( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::Input( { Config => $self->Config } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my ($sure);

	system("clear");

	$control->Title('WARNING');
	$control->appendText( '\Zb\Z4ACCOUNT ' . $user . ' '                               );
	$control->appendText( 'WILL BE COMPLETELY REMOVED FROM THE SYSTEM\Zn' . "\n\n"     );
	$control->appendText( 'All database logs for the user will also be removed.'       );
	$control->appendText( '  To maintain auditing integrity, it is recommended'        );
	$control->appendText( ' that user accounts be locked instead of removed.' . "\n\n" );
	$control->appendText( 'Type '. '\Zb\Z2YES\Zn in all caps if you are sure.' . "\n"  );
	$control->CancelButton(1);
	$control->Height(14);
	$control->Width(70);

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$sure = $control->Data;
	return unless($sure);

	if($sure ne 'YES') {
		$message->Title('Action Cancelled');
		$message->Text('User \Zb\Z4' . $user . ' \Znwas not removed.' . "\n");
		$message->show();
		return;
	}

	$user_obj->UserName($user);

	unless($user_obj->delUser()) {
		my $last_error = $user_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The user was not removed.' . "\n"    );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error removing user $user:  $last_error");
		return;
	}

	$message->Title('Account Removed');
	$message->Text('Account \Zb\Z4' . $user . '\Zn has been removed.');
	$message->Height(5);
	$message->show();

	$self->Log->info("User $user removed");
	return;
}

sub forcePasswordChange {
	my ($self, $user) = @_;
	my $user_obj = new SSHJump::System::User( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	$user_obj->UserName($user);

	unless($user_obj->forcePasswordChange()) {
		my $last_error = $user_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error forcing password change for $user:  $last_error");
		return;
	}

	$message->Title('Change Completed');
	$message->appendText( '\Zb\Z4' . ucfirst($user) . '\Zn will be required to '    );
	$message->appendText(	'change their password the next time they log in.' . "\n" );
	$message->Height(6);
	$message->show();

	$self->Log->info("Forced plddfjassword change for $user");
	return;
}

sub genKey {
	my ($self) = @_;
	my $o_key   = new SSHJump::DB::SSHKey( { DBH => $self->DBH } );
	my $control = new SSHJump::App::Control::Input( { Config => $self->Config } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my ($o_sshkeygen, $file, $key_path);

	system("clear");

	$control->Title('Generate New SSH Key');
	$control->Text( 'Enter the base key name.');
	$control->CancelButton(1);
	$control->Height(8);
	$control->Width(50);

	$control->show();
	return if($control->ExitMsg eq 'NO/CANCEL');

	$file = $control->Data;
	return unless($file);
	return unless($self->inputCheck($file, 'File'));

	$key_path = $self->Config->{'SSH_KEY_DIR'} . '/' . $file;
	$o_key->Location($key_path);

	# Check to see if the key has already been registered...
	if($o_key->SSHKeyID) {
		$message->Title('WARNING');
		$message->Text( 'Key has already been registered:' . "\n" );
		$message->appendText( '\Zb\Z4' . $key_path . '\Zn' );
		$message->Height(7);
		$message->show();

		$self->Log->warning("Key $key_path already registered");
		return;
	}

	$o_sshkeygen = new SSHJump::System::Call::SshKeygen( {
		KeyName => $file,
		KeyDir  => $self->Config->{'SSH_KEY_DIR'}
	} );

	if($o_sshkeygen->ExitCode) {
		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n" );
		$message->appendText( 'ssh-keygen exited with status '    );
		$message->appendText( $o_sshkeygen->ExitCode              );
		$message->show();

		$self->Log->error('Error generating key ' . $file);
		return;
	}

	unless($o_key->addKey()) {
		my $last_error = $o_key->lastError;

		$message->Title('ERROR');
		$message->appendText( 'A fatal error has occured.' . "\n"   );
		$message->appendText( 'The key was not added.' . "\n"       );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error adding key $key_path:  $last_error");
		return;
	}

	$message->Title('SSH Keys Generated');
	$message->Text( 'SSH private key has been created:' . "\n" );
	$message->appendText( '\Zb\Z4' . $self->Config->{'SSH_KEY_DIR'} . '/' . $file . '\Zn' . "\n\n" );
	$message->appendText( 'SSH public key has been created:' . "\n" );
	$message->appendText( '\Zb\Z4' . $self->Config->{'SSH_KEY_DIR'} . '/' . $file . '.pub\Zn' . "\n\n" );
	$message->Height(12);
	$message->show();

	$self->Log->info('SSH Key created:  ' . $file);
	return;
}

sub lockHost {
	my ($self, $host) = @_;
	my $o_host = new SSHJump::DB::Host( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	$o_host->HostName($host);
	$o_host->Active('N');

	unless($o_host->updateHost()) {
		my $last_error = $o_host->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error locking host $host:  $last_error");
		return;
	}

	$message->Title('Host Locked');
	$message->Text('Successfully locked host:' . "\n");
	$message->appendText('\Zb\Z4' . $host . '\Zn');
	$message->Height(6);
	$message->show();

	$self->Log->info("$host has been locked");
	return;
}

sub lockUser {
	my ($self, $user) = @_;
	my $user_obj = new SSHJump::System::User( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	$user_obj->UserName($user);

	unless($user_obj->lockUser()) {
		my $last_error = $user_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error locking account $user:  $last_error");
		return;
	}

	$message->Title('Account Locked');
	$message->Text('Successfully locked account:' . "\n");
	$message->appendText('\Zb\Z4' . $user . '\Zn');
	$message->Height(6);
	$message->show();

	$self->Log->info("$user has been locked");
	return;
}

sub modifyHostData {
	my ($self, $host) = @_;
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my $control = new SSHJump::App::Control::Input( { Config => $self->Config } );
	my $o_host = new SSHJump::DB::Host( { DBH => $self->DBH, HostName => $host } );
	my ($customer);

	$control->Title('Modify Host Data');
	$control->Text('For host \Zb\Z4' . $host . '\Zn' . "\n");
	$control->appendText('Current customer = \Zb\Z4' . $o_host->Customer . '\Zn' . "\n\n");
	$control->appendText('Enter new value:');
	$control->Height(12);
	$control->CancelButton(1);

	$control->show();
	return if($control->ExitMsg eq 'ESC');
	return if($control->ExitMsg eq 'NO/CANCEL');

	$customer = $control->Data;
	return unless($customer);
	return if($customer =~ m/^locked$/i);

	$o_host->Customer($customer);

	unless($o_host->updateHost()) {
		my $last_error = $o_host->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error updating host $host:  $last_error");
		return;
	}

	$message->Title('Host Updated');
	$message->Text( 'Successfully updated host \Zb\Z4' . $host . '\Zn.' );
	$message->Height(5);
	$message->show();

	$self->Log->info("$host has been updated: customer set to $customer");
	return;
}

sub modifyUserData {
	my ($self, $user) = @_;
	my ($username, $password, $real_name, $email);
	my ($phone, $user_obj, $last_error);
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my $control = new SSHJump::App::Control::UserData( {
		DBH    => $self->DBH,
		Config => $self->Config
	} );

	$control->User($user);
	$control->show();
	return if($control->ExitMsg eq 'ESC');
	return if($control->ExitMsg eq 'NO/CANCEL');

	$user_obj = new SSHJump::System::User( { DBH      => $self->DBH,
                                           UserName => $user } );

	if($user eq $self->CurrentUser) {
		( $real_name,
		  $email,
		  $phone ) = @{$control->Data};
	} else {
		( $password,
		  $real_name,
		  $email,
		  $phone ) = @{$control->Data};
	}

	if( (!defined $password || $password eq '********') &&
	    ($user_obj->RealName eq $real_name) &&
	    ($user_obj->Email eq $email) &&
	    ($user_obj->Phone eq $phone) ) {
		return;
	}

	return unless($self->inputCheck($password, 'Password', 'password'));
	return unless($self->inputCheck($real_name, 'Real Name', 'alpha_numeric_space'));
	return unless($self->inputCheck($email, 'Email', 'email'));
	return unless($self->inputCheck($phone, 'Phone', 'phone'));

	$user_obj->RealName($real_name);
	$user_obj->Email($email);
	$user_obj->Phone($phone);

	unless($user_obj->updateUser()) {
		$last_error = $user_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error updating account $user:  " . $last_error);
		return;
	}

	if($password && $password ne '********') {
		$user_obj->Password($password);

		unless($user_obj->changePassword()) {
			$last_error = $user_obj->lastError;

			$message->Title('ERROR');
			$message->appendText( 'The system encountered errors, please see an Admin.' );
			$message->appendText( "\n" . '\Zb\Z4' . $last_error . '\Zn' . "\n"          );
			$message->show();

			$self->Log->error("Error changing password for $user:  " . $last_error);
			return;
		}

		unless($user_obj->forcePasswordChange()) {
			$last_error = $user_obj->lastError;

			$message->Title('ERROR');
			$message->appendText( 'An error has occured.' . "\n"        );
			$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
			$message->show();

			$self->Log->error("Error forcing password change for $user:  $last_error");
			return;
		}
	}

	$message->Title('Account Updated');
	$message->Text('Successfully updated account \Zb\Z4' . $user . '\Zn.');
	$message->Height(5);
	$message->show();

	$self->Log->info("Account $user has been updated");
	return;
}

sub passwordChange {
	my ($self) = @_;
	my ($first_password, $second_password);
	my $control = new SSHJump::App::Control::Password( { Config => $self->Config } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my $user_obj = new SSHJump::System::User( { DBH      => $self->DBH,
	                                            UserName => $self->CurrentUser } );

	$control->Title('Change Password');
	$control->Text('Enter your \Zb\Z4NEW\Zn Password');
	$control->show();

	$first_password = $control->Data;
	return unless($first_password);

	$control = new SSHJump::App::Control::Password( { Config => $self->Config } );

	$control->Title('Change Password');
	$control->Text('Re-enter your \Zb\Z4NEW\Zn Password');
	$control->show();

	$second_password = $control->Data;
	return unless($second_password);

	unless($first_password eq $second_password) {
		$message->Title('ERROR');
		$message->Text('Password mismatch.  Your password was not changed.');
		$message->show();

		return;
	}

	$user_obj->Password($first_password);

	unless($user_obj->changePassword()) {
		$message->Title('ERROR');
		$message->appendText( 'The system encountered errors, please see an Admin.' );
		$message->appendText( "\n" . '\Zb\Z4' . $user_obj->lastError . '\Zn' . "\n" );
		$message->show();

		my $msg  = 'Password change error ' . $self->CurrentUser;
		   $msg .= ': ' . $user_obj->lastError;
		$self->Log->error($msg);
		return;
	}

	$message->Title('Change Complete');
	$message->Text('Your password has been changed.');
	$message->show();

	$self->Log->info($self->CurrentUser . ' has changed their password');
	return;
}

sub scriptPlayback {
	my ($self, $session_id, $speed) = @_;
	my $session_obj = new SSHJump::DB::Session( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my ($log_file, $archive_file, $playback_dir, $command, $base_file);

	my @chars = ('a' .. 'z', 'A' .. 'Z', 0 .. 9);
	my $random_string = join('', @chars[ map { rand @chars} ( 1 .. 12) ]);

	$session_obj->SessionID($session_id);
	$session_obj->getSessionFromID();
	$log_file = basename($session_obj->LogFile);

	return unless($log_file);

	system("clear");

	$base_file = $log_file;
	$base_file =~ s/\.log$//;

	$archive_file  = $self->Config->{'SCRIPT_LOG_DIR'} . '/archive/';
	$archive_file .= $base_file . '.tar.bz2';

	unless( -f $archive_file ) {
		$message->Title('ERROR');
		$message->Text( 'The system could not find the specified log archive.  ' );
		$message->appendText( 'It can take up to a minute for the log files to ' );
		$message->appendText( 'be processed after end of session.  ' );
		$message->show();

		$self->Log->error('Could not find archive:  ' . $archive_file);
		return;
	}

	$playback_dir  = $self->Config->{'SCRIPT_PLAYBACK_DIR'};
	$playback_dir .= '/.' . $random_string;

	SSHJump::Utils::prepareDirectory($playback_dir);

	system('/bin/tar -xjpf ' . $archive_file . ' -C ' . $playback_dir);

	$speed = ($speed) ? $speed : 1;

	$command  = '/usr/bin/scriptreplay ' . $playback_dir . '/';
	$command .= $base_file . '.timing ' . $playback_dir . '/';
	$command .= $log_file . ' ' . $speed;

	$self->Log->info('Archive playback:  ' . $archive_file);

	system($command);
	system('rm -r ' . $playback_dir);

	while(1) {
		my $i = '';

		# This code captures hitting the ENTER key.
		# I have no idea how this works...
		vec($i, fileno(STDIN), 1) = 1;
		last if(select($i, undef, undef, 0));

		print "Hit ENTER to continue...\r";
	}

	return;
}

sub sshConnect {
	my ($self, $host_str) = @_;
	my ($host, $group_id, $ssh_command, $script_command);
	my ($command_obj, $output, $rv);
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );
	my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );
	my $sshkey_obj = new SSHJump::DB::SSHKey( { DBH => $self->DBH } );

	if($host_str =~ m/^(\w+)\[(\d+)\]$/) {
		$host = $1;
		$group_id = $2;
	} else {
		return;
	}

	$group_obj->GroupID($group_id);
	$sshkey_obj->SSHKeyID($group_obj->SSHKeyID);

	$self->Log->info('Opening SSH session: ' . $host . ':' . $group_obj->RemoteUser);

	$command_obj = new SSHJump::Script::SSH( {
		LogDir     => $self->Config->{'SCRIPT_LOG_DIR'},
		User       => $self->CurrentUser,
		Host       => $host,
		RemoteUser => $group_obj->RemoteUser,
		Key        => $sshkey_obj->Location,
		Log        => $self->Log
	} );

	$rv = SSHJump::Utils::xlateExitCode($command_obj->execute());

	if($rv) {
		$message->Title('SSH Connection Error');
		$message->Text('Could not open shell to \Zb\Z4' . $host . '\Zn');
		$message->show();

		$self->Log->error('Encountered problems executing ssh connection to ' . $host);
	}

	$self->Log->info('Closing SSH session: ' . $host . ':' . $group_obj->RemoteUser);
	return;
}

sub unlockHost {
	my ($self, $host) = @_;
	my $o_host = new SSHJump::DB::Host( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	system("clear");
	$o_host->HostName($host);
	$o_host->Active('Y');

	unless($o_host->updateHost()) {
		my $last_error = $o_host->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error unlocking host $host:  $last_error");
		return;
	}

	$message->Title('Host Unlocked');
	$message->Text('Successfully unlocked host:' . "\n");
	$message->appendText('\Zb\Z4' . $host . '\Zn');
	$message->Height(6);
	$message->show();

	$self->Log->info("$host has been unlocked");
	return;
}

sub unlockUser {
	my ($self, $user) = @_;
	my $user_obj = new SSHJump::System::User( { DBH => $self->DBH } );
	my $message = new SSHJump::App::Control::Message( { Config => $self->Config } );

	system("clear");
	$user_obj->UserName($user);

	unless($user_obj->unlockUser()) {
		my $last_error = $user_obj->lastError;

		$message->Title('ERROR');
		$message->appendText( 'An error has occured.' . "\n"        );
		$message->appendText( '\Zb\Z4' . $last_error . '\Zn' . "\n" );
		$message->show();

		$self->Log->error("Error unlocking account $user:  $last_error");
		return;
	}

	$message->Title('Account Unlocked');
	$message->Text('Successfully unlocked account:' . "\n");
	$message->appendText('\Zb\Z4' . $user . '\Zn');
	$message->Height(6);
	$message->show();

	$self->Log->info("$user has been unlocked");
	return;
}

### Generic Method Definitions #################################################

no Moose;

1;
