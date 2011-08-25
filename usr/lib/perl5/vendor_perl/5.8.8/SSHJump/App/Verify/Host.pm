package SSHJump::App::Verify::Host;

use Moose;

extends 'SSHJump::App::Verify', 'SSHJump::Verify::Host';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	unless($self->Verified) {
		$self->{'Error'}  = "\n" . '\Zb\Z4' . $self->Host . '\Zn does not';
		$self->{'Error'} .= ' appear to be a valid host name.' . "\n";
	}
}

no Moose;

1;
