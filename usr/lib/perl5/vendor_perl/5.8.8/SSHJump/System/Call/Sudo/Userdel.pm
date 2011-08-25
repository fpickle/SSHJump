package SSHJump::System::Call::Sudo::Userdel;

use Moose;

extends 'SSHJump::System::Call::Sudo';

# String Properties

# List Properties
has 'EXIT_CODES' => ( is => 'ro', isa => 'HashRef', default => sub {
	{
		0  => 'success',
		1  => 'cannot update password file',
		2  => 'invalid command syntax',
		6  => 'specified user does not exist',
		8  => 'user currently logged in',
		10 => 'cannot update group file',
		12 => 'cannot remove home directory'
	}
} );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Command'} = '/usr/sbin/userdel';
	$self->{'Command'} .= ' -r';
	$self->{'Command'} .= ' ' . $self->User;

	$self->execute();
}

no Moose;

1;
