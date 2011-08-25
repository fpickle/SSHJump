package SSHJump::Verify::String;

use Moose;

use SSHJump::Verify;

# String Properties
has 'String' => ( is => 'rw', isa => 'Str', required => 1 );

# Public Methods
sub verify {
	my ($self) = @_;
	return 1 if($self->String =~ STRING_REGEX);
	return 0;
}

# Private Methods

no Moose;

1;
