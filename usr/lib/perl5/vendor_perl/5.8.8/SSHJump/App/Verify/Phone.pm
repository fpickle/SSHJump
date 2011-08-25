package SSHJump::App::Verify::Phone;

use Moose;

extends 'SSHJump::App::Verify', 'SSHJump::Verify::Phone';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	unless($self->Verified) {
		$self->{'Error'}  = "\n" . '\Zb\Z4' . $self->Phone . '\Zn does ';
		$self->{'Error'} .= 'not appear to be a valid phone number.' . "\n"
	}
}

no Moose;

1;
