package SSHJump::App::Control::SSHKeyRadio;

use Moose;
use SSHJump::App::Control::Message;
use SSHJump::DB::Collection::SSHKey;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::RadioList';

use constant DEFAULT_HEIGHT => 20;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 10;

# String Properties
has 'User'  => ( is      => 'rw',
                 isa     => 'Str',
                 default => '',
                 trigger => \&_load );
has 'Group' => ( is      => 'rw',
                 isa     => 'Str',
                 default => '',
                 trigger => \&_load );

# Database Handle
has 'DBH'   => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('SSH Key Select');
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ListHeight(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;
	my $c_key = new SSHJump::DB::Collection::SSHKey({DBH => $self->DBH});
	my $message = new SSHJump::App::Control::Message({Config => $self->Config });

	return unless($self->User && $self->Group);

	$self->appendText('Select the SSH key for account \Zb\Z4' . $self->User    );
	$self->appendText('\Zn in \Zb\Z4' . $self->Group . '\Zn.  If you do not '  );
	$self->appendText('make a selection, the current action will be cancelled.');

	if($c_key->Collection) {
		foreach my $o_key (@{$c_key->Collection}) {
			$self->addItem([$o_key->Location, '', 'off']);
		}
	} else {
		$message->Title('Missing SSH Keys');
		$message->appendText('No keys have been registered.  Please '      );
		$message->appendText('select the KEY option from the main menu and');
		$message->appendText(' register an ssh key before adding a group.' );
		$message->show();
		return;
	}
}

no Moose;

1;
