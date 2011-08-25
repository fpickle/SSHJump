package SSHJump::System::Call::Script::RemoteCommand;

use Moose;

extends 'SSHJump::System::Call::Script';

# Properties
has 'RemoteCommand' => ( is => 'rw', isa => 'CleanStr', required => 1 );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->_prepareLogDir();
	$self->_generateFileBase();

	$self->{Command}  = '/usr/bin/ssh -l ' . "'" . $self->RemoteUser . "'";
	$self->{Command} .= " -tt -i '" . $self->Key . "' " . $self->Host;
	$self->{Command} .= " '" . $self->RemoteCommand . "'";
}

no Moose;

1;
