package SSHJump::App::Control::GroupOptions;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 11;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 4;

# String Properties
has 'Group' => ( is      => 'rw',
                 isa     => 'Str',
                 default => '',
                 trigger => \&_load );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('Group Management');
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;

	$self->Text('Options for group \Zb\Z4' . $self->Group . '\Zn:');

	$self->addItem({'HOSTS' => 'Add/Remove hosts from ' . $self->Group    });
	$self->addItem({'USERS' => 'Add/Remove user access to ' . $self->Group});
	$self->addItem({'REMOVE' => 'Remove ' . $self->Group                  });
	#$self->addItem( { 'VIEW' => 'View group information' } );
	$self->addItem({'BACK' => 'Return to previous menu'                   });
}

no Moose;

1;
