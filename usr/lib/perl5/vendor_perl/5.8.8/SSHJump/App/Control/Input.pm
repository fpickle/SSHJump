package SSHJump::App::Control::Input;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog';

use constant DEFAULT_HEIGHT => 10;
use constant DEFAULT_WIDTH  => 50;

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Type('inputbox');
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->OKButton(1);
}

no Moose;

1;
