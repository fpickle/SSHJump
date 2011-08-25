package SSHJump::App::Control::HostManagement;

use Moose;
use SSHJump::DB::Collection::Host;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 19;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 10;

# Database Handle
has 'DBH' => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $c_host = new SSHJump::DB::Collection::Host({DBH => $self->DBH});

	$self->Title('Host Management');

	$self->appendText('Choose \Zb\Z4ADD\Zn to add a new host.  '    );
	$self->appendText('Otherwise, choose the host to modify.' . "\n");
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);

	$self->addItem({'ADD' => 'Add a new host'});

	foreach my $o_host (@{$c_host->Collection}) {
		if($o_host->Active eq 'N') {
			$self->addItem({$o_host->HostName => 'LOCKED' });
		} else {
			$self->addItem({$o_host->HostName => $o_host->Customer});
		}
	}

	$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
