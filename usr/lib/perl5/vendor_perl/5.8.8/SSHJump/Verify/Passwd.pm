package SSHJump::Verify::Passwd;

use Moose;

use SSHJump::Verify;

# String Properties
has 'Passwd' => ( is => 'rw', isa => 'Str', required => 1 );

# Public Methods
sub verify {
	my ($self) = @_;
	return 1 if($self->Passwd =~ PASSWD_REGEX);
	return 0;
}

# Private Methods

no Moose;

1;
