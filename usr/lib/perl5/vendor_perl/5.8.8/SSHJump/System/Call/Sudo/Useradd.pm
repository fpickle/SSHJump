package SSHJump::System::Call::Sudo::Useradd;

use Moose;

extends 'SSHJump::System::Call::Sudo';

# String Properties
has 'Group'             => ( is => 'rw', isa => 'CleanStr', default => '' );

# List Properties
has 'EXIT_CODES' => ( is => 'ro', isa => 'HashRef', default => sub {
	{
		0  => 'success',
		1  => 'cannot update password file',
		2  => 'invalid command syntax',
		3  => 'invalid argument to option',
		4  => 'UID already in use',
		6  => 'specified group does not exist',
		9  => 'username already in use',
		10 => 'cannot update group file',
		12 => 'cannot create home directory',
		13 => 'cannot create mail spool'
	}
} );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Command'} = '/usr/sbin/useradd';

	if($self->Password) {
		$self->_encryptPassword();
		$self->{'Command'} .= " -p '" . $self->EncryptedPassword . "'";
	}

	$self->{'Command'} .= ' -G ' . $self->Group if($self->Group);
	$self->{'Command'} .= ' ' . $self->User;

	$self->execute();
}

no Moose;

1;
