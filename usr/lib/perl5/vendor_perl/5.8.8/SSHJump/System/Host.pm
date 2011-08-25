package SSHJump::System::Host;

use Moose;

use SSHJump::System::Call::GetEnt;

extends 'SSHJump::DB::Host';

# Properties

# Public Methods
sub resolves {
	my ($self) = @_;
	my $o_getent = new SSHJump::System::Call::GetEnt( {
		Host => $self->HostName
	} );

	return 1 unless($o_getent->ExitCode);
	return 0;
}

# Private Methods

no Moose;

1;
