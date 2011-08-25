package SSHJump::System::Call::GetEnt;

use Moose;

extends 'SSHJump::System::Call';

# String Properties
has 'Host' => ( is => 'rw', isa => 'CleanStr', required => 1 );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;
	$self->{'Command'} = '/usr/bin/getent hosts ' . $self->Host . ' > /dev/null';
	$self->execute();
}

no Moose;

1;
