package SSHJump::App::Control::SessionHistory;

use Moose;
use SSHJump::DB::Collection::Log;

#extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';
extends 'SSHJump::App::Control', 'SSHJump::Dialog';

use constant DEFAULT_HEIGHT => 15;
use constant DEFAULT_WIDTH  => 70;
#use constant DEFAULT_ITEMS  => 7;

# Integer Properties
has 'SessionID' => ( is => 'rw', isa => 'Int', trigger => \&_load );

# Database Handle
has 'DBH'       => ( is => 'rw', isa => 'Object', required => 1);

# Private Methods
sub _load {
	my ($self) = @_;
	my $c_log = new SSHJump::DB::Collection::Log( {
		DBH    => $self->DBH,
		SessionID => $self->SessionID 
	} );

	$self->Title('Session History');
	$self->Type('msgbox');
	#$self->Text('Choose an open session to view account activity.');

	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	#$self->ItemsShown(DEFAULT_ITEMS);

	if($c_log->Collection) {
		foreach my $o_log (@{$c_log->Collection}) {
			$self->appendText($o_log->Entry . "\n\n");
			#$self->addItem({$o_log->LogID => $o_log->Entry});
		}
	}

	#$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
