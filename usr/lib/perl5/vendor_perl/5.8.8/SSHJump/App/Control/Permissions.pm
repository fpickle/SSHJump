package SSHJump::App::Control::Permissions;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 10;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 2;

# String Properties
has 'User' => ( is      => 'rw',
                isa     => 'Str',
                default => '',
                trigger => \&_load );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title($self->Config->{'GUI_NAME'} . ' Permissions');
	$self->Text('Choose user access permissions from the list below.' . "\n");
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;

	$self->Text('Choose access permissions for account' . "\n");
	$self->appendText('\Zb\Z4' . $self->User . '\Zn');
	$self->appendText(' from the list below.' . "\n");
	
	$self->addItem({'SUPERADMIN' => 'All system privileges'});
	$self->addItem({'ADMIN' => 'Command-line access only'});
	# $self->addItem({'USER' => 'Basic permissions; no shell access'});
}

no Moose;

1;
