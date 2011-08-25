package SSHJump::App::Control::SSHKeyManagement;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 10;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 4;

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('SSH Key Management');

	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);

	$self->addItem({'REG'  => 'Register existing key'});
	$self->addItem({'GEN'  => 'Generate and register a new key'});
	$self->addItem({'DREG' => 'Unregister key(s)'});
	$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
