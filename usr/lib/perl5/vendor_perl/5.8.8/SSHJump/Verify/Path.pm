package SSHJump::Verify::Path;

use Moose;

use SSHJump::Verify;

# String Properties
has 'Path' => ( is => 'rw', isa => 'Str', required => 1 );

# Public Methods
sub verify {
	my ($self) = @_;
	return 1 if($self->Path =~ PATH_REGEX);
	return 0;
}

# Private Methods

no Moose;

1;
