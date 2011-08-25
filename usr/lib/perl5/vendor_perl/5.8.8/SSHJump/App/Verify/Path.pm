package SSHJump::App::Verify::Path;

use Moose;

extends 'SSHJump::App::Verify', 'SSHJump::Verify::Path';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	unless($self->Verified) {
		$self->{'Error'}  = $self->Path . ' does not appear';
		$self->{'Error'} .= ' to be a valid path.' . "\n"
	}
}

no Moose;

1;
