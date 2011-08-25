package SSHJump::Verify::Email;

use Moose;

use SSHJump::Verify;

# String Properties
has 'Email' => ( is => 'rw', isa => 'Str', required => 1 );

# Public Methods
sub verify {
	my ($self) = @_;
	return 1 if($self->Email =~ EMAIL_REGEX);
	return 0;
}

# Private Methods

no Moose;

1;
