package SSHJump::System::Call::Script::Service;

use Moose;

extends 'SSHJump::System::Call::Script';

# Properties
has 'Service' => ( is => 'rw', isa => 'CleanStr', required => 1 );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->_prepareLogDir();
	$self->_generateFileBase();

	$self->{Command}  = '/usr/bin/ssh -l ' . "'" . $self->RemoteUser . "'";
	$self->{Command} .= " -tt -i '" . $self->Key . "' " . $self->Host;
	$self->{Command} .= " 'sudo /sbin/service " . $self->Service . " restart'";
}

no Moose;

1;
