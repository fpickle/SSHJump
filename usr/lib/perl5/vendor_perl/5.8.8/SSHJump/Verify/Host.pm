package SSHJump::Verify::Host;

use Moose;

use SSHJump::Verify;

# String Properties
has 'Host' => ( is => 'rw', isa => 'Str', required => 1 );

# Public Methods
sub verify {
	my ($self) = @_;
	return 1 if($self->Host =~ HOST_REGEX);
	return 0;
}

# Private Methods

no Moose;

1;
