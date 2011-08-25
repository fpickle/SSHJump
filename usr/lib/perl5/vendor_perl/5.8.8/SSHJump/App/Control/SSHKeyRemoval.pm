package SSHJump::App::Control::SSHKeyRemoval;

use Moose;
use SSHJump::App::Control::Message;
use SSHJump::DB::Collection::SSHKey;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::CheckList';

use constant DEFAULT_HEIGHT => 20;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 10;

# Database Handle
has 'DBH'   => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $c_key = new SSHJump::DB::Collection::SSHKey({DBH => $self->DBH});
	my $message = new SSHJump::App::Control::Message({Config => $self->Config });

	$self->Title('SSH Key Removal');
	$self->Text('Select the SSH key(s) for removal.');
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ListHeight(DEFAULT_ITEMS);
	$self->CancelButton(1);

	if($c_key->Collection) {
		foreach my $o_key (@{$c_key->Collection}) {
			$self->addItem([$o_key->Location, '', 'off']);
		}
	} else {
		$message->Title('Missing SSH Keys');
		$message->Text('No keys have been registered.');
		$message->show();
		return;
	}
}

no Moose;

1;
