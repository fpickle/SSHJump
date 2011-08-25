package SSHJump::App::Verify::Email;

use Moose;

extends 'SSHJump::App::Verify', 'SSHJump::Verify::Email';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	unless($self->Verified) {
		$self->{'Error'}  = "\n" . '\Zb\Z4' . $self->Email . '\Zn does not';
		$self->{'Error'} .= ' appear to be a valid email address.' . "\n";
	}
}

no Moose;

1;
