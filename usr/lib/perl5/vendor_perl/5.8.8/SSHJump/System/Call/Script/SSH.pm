package SSHJump::System::Call::Script::SSH;

use Moose;

extends 'SSHJump::System::Call::Script';

# Properties

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->_prepareLogDir();
	$self->_generateFileBase();

	$self->{Command}  = '/usr/bin/ssh -l ' . "'" . $self->RemoteUser . "'";
	$self->{Command} .= " -i '" . $self->Key . "' " . $self->Host;
}

no Moose;

1;
