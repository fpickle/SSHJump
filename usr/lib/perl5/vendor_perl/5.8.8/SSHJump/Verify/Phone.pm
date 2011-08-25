package SSHJump::Verify::Phone;

use Moose;

use SSHJump::Verify;

# String Properties
has 'Phone' => ( is => 'rw', isa => 'Str', required => 1 );

# Public Methods
sub verify {
	my ($self) = @_;
	return 1 if($self->Phone =~ PHONE_REGEX);
	return 0;
}

# Private Methods

no Moose;

1;
