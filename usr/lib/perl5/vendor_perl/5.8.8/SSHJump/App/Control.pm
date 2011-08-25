package SSHJump::App::Control;

use Moose;
use SSHJump::Utils;

# Function References
has 'EscapeHandler' => ( is => 'rw', isa => 'CodeRef' );
has 'ExitHandler'   => ( is => 'rw', isa => 'CodeRef' );

# String Properties
has 'CurrentUser'   => ( is => 'ro', isa => 'Str', default => ''      );
has 'Data'          => ( is => 'ro', isa => 'Str', default => ''      );
has 'TempDir'       => ( is => 'rw', isa => 'CleanStr', default => '' );

# Configuration HashRef
has 'Config'        => ( is => 'rw', isa => 'HashRef', required => 1 );

# Public Methods
sub show {
	my ($self) = @_;
	$self->render();

	if( ($self->ExitMsg eq 'ESC') && ($self->EscapeHandler) ) {
		&{$self->EscapeHandler};
	}

	$self->{Data} = $self->getData();
}

# Private Methods
sub BUILD {
	my ($self) = @_;
	$self->{'CurrentUser'} = SSHJump::Utils::getCurrentUser();

	# These hard coded values need to be retrieved from the configuration file...
	$self->{'TempDir'} = $self->Config->{'DIALOG_DIR'};
}

no Moose;

1;
