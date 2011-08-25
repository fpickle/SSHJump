package SSHJump::System::Call::Sudo::Chage;

use Moose;

extends 'SSHJump::System::Call::Sudo';

# String Properties

# List Properties
has 'EXIT_CODES' => ( is => 'ro', isa => 'HashRef', default => sub {
	{
		0  => 'success',
		1  => 'permission denied',
		2  => 'invalid command syntax',
		15 => 'cannot find the shadow password file'
	}
} );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Command'} = '/usr/bin/chage';
	$self->{'Command'} .= ' -d0';
	$self->{'Command'} .= ' ' . $self->User;

	$self->execute();
}

no Moose;

1;
