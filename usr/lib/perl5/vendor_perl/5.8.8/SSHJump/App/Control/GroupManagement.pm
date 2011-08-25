package SSHJump::App::Control::GroupManagement;

use Moose;
use SSHJump::DB::Collection::Group;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 19;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 10;

# Database Handle
has 'DBH' => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $c_group  = new SSHJump::DB::Collection::Group({DBH => $self->DBH});

	$self->Title('Group Management');

	$self->appendText('Choose \Zb\Z4ADD\Zn to add a new group.  '    );
	$self->appendText('Otherwise, choose the group to modify.' . "\n");
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);

	$self->addItem({'ADD' => 'Add a new group'});

	if($c_group->Collection) {
		foreach my $o_group (@{$c_group->Collection}) {
			$self->addItem({$o_group->GroupName => $o_group->Description});
		}
	}

	$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
