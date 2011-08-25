package SSHJump::App::Control::ProfileOptions;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 10;
use constant DEFAULT_WIDTH  => 60;

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $gui_name = $self->Config->{'GUI_NAME'};

	$self->Title('\Zb\Z4' . ucfirst($self->CurrentUser) . '\Zn Profile Options');
	$self->Text('Modify your user profile:');
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->CancelButton(1);

	$self->addItem({'PASS' => 'Change your ' . $gui_name . ' password'   });
	$self->addItem({'DATA' => 'Change your ' . $gui_name . ' information'});
	$self->addItem({'BACK' => 'Return to previous menu'                  });
}

no Moose;

1;
