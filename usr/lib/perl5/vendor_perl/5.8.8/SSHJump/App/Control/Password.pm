package SSHJump::App::Control::Password;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::PasswordBox';

use constant DEFAULT_HEIGHT => 8;
use constant DEFAULT_WIDTH  => 50;

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
}

no Moose;

1;
