package SSHJump::Verify::AlphaNumeric;

use Moose;

use SSHJump::Verify;

# String Properties
has 'String'  => ( is => 'rw', isa => 'Str', required => 1 );

# Boolean Properties
has 'NoSpace' => ( is => 'rw', isa => 'Int', default => 1  );

# Public Methods
sub verify {
	my ($self) = @_;

	if($self->NoSpace) {
		return 1 if($self->String =~ ALPHNUM_REGEX);
	} else {
		return 1 if($self->String =~ ALPHNUM_SPACE_REGEX);
	}

	return 0;
}

# Private Methods

no Moose;

1;
