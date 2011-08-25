package SSHJump::App::Control::UserManagement;

use Moose;
use SSHJump::DB::Collection::User;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 18;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 10;

# Database Handle
has 'DBH' => (is => 'rw', isa => 'Object', required => 1);

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $c_user = new SSHJump::DB::Collection::User({'DBH' => $self->DBH});

	$self->Title('User Management');

	$self->appendText('Choose \Zb\Z4ADD\Zn to add a new user.  '    );
	$self->appendText('Otherwise, choose the user to modify.' . "\n");
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);

	$self->addItem({'ADD' => 'Add a new user'});

	if($c_user->Collection) {
		foreach my $o_user (@{$c_user->Collection}) {
			next if($o_user->UserName eq $self->CurrentUser);

			if($o_user->Active eq 'N') {
				$self->addItem({$o_user->UserName => 'LOCKED' });
			} else {
				$self->addItem({$o_user->UserName => $o_user->Access});
			}
		}
	}

	$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
