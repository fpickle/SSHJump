package SSHJump::App::Verify::Passwd;

use Moose;

extends 'SSHJump::App::Verify', 'SSHJump::Verify::Passwd';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	unless($self->Verified) {
		$self->{'Error'}  = 'Password must be at least 8 characters long.' . "\n";
	}
}

no Moose;

1;
