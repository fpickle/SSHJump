package SSHJump::App::Control::HostOptions;

use Moose;
use SSHJump::DB::Host;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 13;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 6;

# String Properties
has 'Host' => ( is      => 'rw',
                isa     => 'Str',
                default => '',
                trigger => \&_load );

# Database Handle
has 'DBH'  => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('Host Management');
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;
	my $o_host = new SSHJump::DB::Host({DBH => $self->DBH });

	$o_host->HostName($self->Host);

	$self->Text('Options for host \Zb\Z4' . $self->Host . '\Zn:');

	if($o_host->Active eq 'N') {
		$self->addItem({'UNLOCK' => 'Unlock host'        });
	} else {
		$self->addItem({'GROUPS' => 'Manage host groups' });
		$self->addItem({'UPDATE' => 'Set customer'       });
		$self->addItem({'ALIAS' => 'Add alias'           });
		$self->addItem({'DALIAS' => 'Remove alias'       });
		$self->addItem({'LOCK' => 'Lock host'            });
		#$self->addItem({'REMOVE' => 'Remove host'       });
		#$self->addItem({'VIEW' => 'View aliases'        });
	}

	$self->addItem({'BACK' => 'Return to previous menu' });
}

no Moose;

1;
