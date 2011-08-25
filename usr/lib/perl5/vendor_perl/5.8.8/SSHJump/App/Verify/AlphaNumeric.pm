package SSHJump::App::Verify::AlphaNumeric;

use Moose;

extends 'SSHJump::App::Verify', 'SSHJump::Verify::AlphaNumeric';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	unless($self->Verified) {
		$self->{'Error'}  = "\n" . '\Zb\Z4' . $self->String . '\Zn does not';
		$self->{'Error'} .= ' appear to be a valid alpha-numeric string.' . "\n";
	}
}

no Moose;

1;
