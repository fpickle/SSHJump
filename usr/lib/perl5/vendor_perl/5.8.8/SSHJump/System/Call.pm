package SSHJump::System::Call;

use Moose;

use SSHJump::Moose::Types;

# String Properties
has 'Command'     => ( is => 'ro', isa => 'Str', default => '' );
has 'ExitMessage' => ( is => 'ro', isa => 'Str', default => '' );

# Integer Properties
has 'ExitCode'    => ( is => 'ro', isa => 'Int', default => 0  );

# Object Properties
has 'Log'         => ( is => 'ro', isa => 'Log' );

# Public Methods
sub execute {
	my ($self) = @_;

	return 0 unless($self->Command);

	$self->Log->info('EXECUTE:  ' . $self->Command) if($self->Log);
	$self->{'ExitCode'} = system($self->Command) >> 8;

	if(exists $self->{'EXIT_CODES'}) {
		$self->{'ExitMessage'} = $self->EXIT_CODES->{$self->ExitCode};
	}
}

# Private Methods

no Moose;

1;
