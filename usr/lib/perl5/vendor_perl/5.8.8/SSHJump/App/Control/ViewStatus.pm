package SSHJump::App::Control::ViewStatus;

use Moose;
use SSHJump::DB::Log;
use SSHJump::DB::User;
use SSHJump::DB::Collection::Session;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 15;
use constant DEFAULT_WIDTH  => 70;
use constant DEFAULT_ITEMS  => 7;

# Database Handle
has 'DBH'  => (is => 'rw', isa => 'Object', required => 1); 

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $c_session = new SSHJump::DB::Collection::Session( {
		DBH    => $self->DBH,
		Status => 'OPEN'
	} );

	$self->Title('Open Sessions');
	$self->Text('Choose an open session to view account activity.');

	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);

	if($c_session->Collection) {
		foreach my $o_session (@{$c_session->Collection}) {
			my $o_log = new SSHJump::DB::Log( { DBH => $self->DBH } );
			my $o_user = new SSHJump::DB::User( { DBH => $self->DBH } );
			my ($tag, $description);

			$o_log->SessionID($o_session->SessionID);
			$o_log->getUserHostFromSession();

			$o_user->UserID($o_log->UserID);

			$tag = $o_user->UserName . '[' . $o_session->SessionID . ']';

			$description = sprintf( '%-20s%4s',
			                        $o_session->TimeOpened,
			                        $o_session->Type );

			$self->addItem({$tag => $description});
		}
	}

	$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
