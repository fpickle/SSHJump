package SSHJump::App::Control::UserOptions;

use Moose;
use SSHJump::DB::User;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 13;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 6;

# String Properties
has 'User' => ( is      => 'rw',
                isa     => 'Str',
                default => '',
                trigger => \&_load );

# Database Handle
has 'DBH'  => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('User Management');
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;
	my $o_user = new SSHJump::DB::User({DBH => $self->DBH});

	$o_user->UserName($self->User);

	$self->Text('Options for account \Zb\Z4' . $self->User . '\Zn:');

	if($o_user->Active eq 'N') {
		$self->addItem({'UNLOCK' => 'Unlock account'});
	} else {
		$self->addItem({'DATA' => 'Update account information'});
		$self->addItem({'PERMS' => 'Update permissions'       });
		$self->addItem({'GROUPS' => 'Modify shell access'    });
		$self->addItem({'FORCE' => 'Force password change'    });
		$self->addItem({'LOCK' => 'Lock account'});
		#$self->addItem({'REMOVE' => 'Remove account'});
	}

	$self->addItem({'BACK' => 'Return to previous menu'   });
}

no Moose;

1;
