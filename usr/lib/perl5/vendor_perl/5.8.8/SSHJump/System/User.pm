package SSHJump::System::User;

use Moose;

use SSHJump::Utils;
use SSHJump::Constants;

use SSHJump::System::Call::Sudo::Chage;
use SSHJump::System::Call::Sudo::Useradd;
use SSHJump::System::Call::Sudo::Userdel;
use SSHJump::System::Call::Sudo::Usermod;

extends 'SSHJump::DB::User';

before 'addUser'   => \&_addUnixUser;
before 'delUser'   => \&_delUnixUser;
before '_loadUser' => \&_checkUnixUser;

# Properties

# Public Methods
sub forcePasswordChange {
	my ($self) = @_;
	my ($o_chage);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot force password change');
		return 0;
	}

	$o_chage = new SSHJump::System::Call::Sudo::Chage( {
		User  => $self->UserName,
	} );

	if($o_chage->ExitCode) {
		my $error_msg = 'Unknown Error';
		$error_msg = $o_chage->ExitMessage if($o_chage->ExitMessage);
		$self->_error($error_msg);
		return 0;
	}

	return 1;
}

sub lockUser {
	my ($self) = @_;
	my ($o_usermod);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot lock user account');
		return 0;
	}

	$o_usermod = new SSHJump::System::Call::Sudo::Usermod( {
		User  => $self->UserName,
		Shell => LOCK_SHELL
	} );

	if($o_usermod->ExitCode) {
		my $error_msg = 'Unknown Error';
		$error_msg = $o_usermod->ExitMessage if($o_usermod->ExitMessage);
		$self->_error($error_msg);
		return 0;
	}

	$self->Active('N');
	return $self->updateUser();
}

sub unlockUser {
	my ($self) = @_;
	my ($o_usermod);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot unlock user account');
		return 0;
	}

	$o_usermod = new SSHJump::System::Call::Sudo::Usermod( {
		User  => $self->UserName,
		Shell => DEFAULT_SHELL
	} );

	if($o_usermod->ExitCode) {
		my $error_msg = 'Unknown Error';
		$error_msg = $o_usermod->ExitMessage if($o_usermod->ExitMessage);
		$self->_error($error_msg);
		return 0;
	}

	$self->Active('Y');
	return $self->updateUser();
}

sub changePassword {
	my ($self) = @_;
	my ($o_usermod);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot change password');
		return 0;
	}

	$o_usermod = new SSHJump::System::Call::Sudo::Usermod( {
		User     => $self->UserName,
		Password => $self->Password
	} );

	if($o_usermod->ExitCode) {
		my $error_msg = 'Unknown Error';
		$error_msg = $o_usermod->ExitMessage if($o_usermod->ExitMessage);
		$self->_error($error_msg);
		return 0;
	}

	return 1;
}

# Private Methods
sub _addUnixUser {
	my ($self) = @_;
	my ($o_useradd);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot add user');
		return 0;
	}

	unless($self->Password) {
		$self->_error('Password undefined.  Cannot add user');
		return 0;
	}

	# Add the user
	$o_useradd = new SSHJump::System::Call::Sudo::Useradd( {
		User     => $self->UserName,
		Group    => SSHJUMP_GROUP,
		Password => $self->Password
	} );

	if($o_useradd->ExitCode) {
		my $error_msg = 'Unknown Error';
		$error_msg = $o_useradd->ExitMessage if($o_useradd->ExitMessage);
		$self->_error($error_msg);
		return 0;
	}

	# Modify user to force password change at next login
	$self->forcePasswordChange();
}

sub _delUnixUser {
	my ($self) = @_;
	my ($o_userdel);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot remove user');
		return 0;
	}

	$o_userdel = new SSHJump::System::Call::Sudo::Userdel( {
		User => $self->UserName
	} );

	if($o_userdel->ExitCode) {
		my $error_msg = 'Unknown Error';
		$error_msg = $o_userdel->ExitMessage if($o_userdel->ExitMessage);
		$self->_error($error_msg);
		return 0;
	}
}

sub _checkUnixUser {
	my ($self) = @_;
	my $id = system('/usr/bin/id ' . $self->UserName . ' > /dev/null 2>&1');

	if($id) {
		$self->_warning('Unix user ' . $self->UserName . 'already exists');
		$self->{Exists}++;
	}
}

no Moose;

1;
