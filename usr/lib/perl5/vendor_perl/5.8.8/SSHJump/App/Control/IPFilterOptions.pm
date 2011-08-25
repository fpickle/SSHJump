package SSHJump::App::Control::IPFilterOptions;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 11;
use constant DEFAULT_WIDTH  => 70;

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $gui_name = $self->Config->{'GUI_NAME'};

	$self->Title('IP Filter Options');
	$self->Text('Configure ip filtering for the ' . $gui_name . ":\n");
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);

	$self->addItem({'DENY' => 'Modify /etc/hosts.deny'  });
	$self->addItem({'ALLOW' => 'Modify /etc/hosts.allow'});
	$self->addItem({'BACK' => 'Return to previous menu' });
}

no Moose;

1;
