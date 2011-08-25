package SSHJump::App::Verify::Space;

use Moose;

extends 'SSHJump::App::Verify', 'SSHJump::Verify::Space';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	if($self->Verified) {
		$self->{'Error'}  = 'Spaces are not allowed in ';
		$self->{'Error'} .= '\Zb\Z4' . $self->Description . '\Zn.' . "\n";
	}
}

no Moose;

1;
