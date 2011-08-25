package SSHJump::App::Control::IPFilter;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog';

use constant DEFAULT_HEIGHT => 40;
use constant DEFAULT_WIDTH  => 80;

# String Properties
has 'File' => ( is => 'rw', isa => 'Str', default => '', required => 1 );

# List Properties
has 'Data' => ( is => 'ro', isa => 'ArrayRef' );

# Public Methods
sub show {
	my ($self) = @_;
	$self->render();

	if( ($self->ExitMsg eq 'ESC') && ($self->EscapeHandler) ) {
		&{$self->EscapeHandler};
	}

	@{$self->{Data}} = $self->getData();
}

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('Editing /etc/' . $self->File);
	$self->Text('/etc/' . $self->File);

	$self->Type('editbox');
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->OKButton(1);
}

no Moose;

1;
