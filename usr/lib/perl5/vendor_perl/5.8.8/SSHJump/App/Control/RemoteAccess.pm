package SSHJump::App::Control::RemoteAccess;

use Moose;
use SSHJump::DB::Collection::User;
use SSHJump::DB::Collection::UserGroup;
use SSHJump::DB::Collection::HostGroup;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 15;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 7;

# Database Handle
has 'DBH'  => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $o_user = new SSHJump::DB::User({DBH => $self->DBH});
	my $c_usergroup = new SSHJump::DB::Collection::UserGroup({DBH => $self->DBH});

	$self->Title('Open Remote Shell');
	$self->Text('Choose the remote server and user:' . "\n");
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);

	$o_user->UserName($self->CurrentUser);
	$c_usergroup->UserID($o_user->UserID);

	if($c_usergroup->Collection) {
		foreach my $o_group (@{$c_usergroup->Collection}) {
			my $parameters = { DBH     => $self->DBH,
			                   GroupID => $o_group->GroupID };
			my $c_hostgroup = new SSHJump::DB::Collection::HostGroup($parameters);

			foreach my $o_host (@{$c_hostgroup->Collection}) {
				my $tag = $o_host->HostName . '[' . $o_group->GroupID . ']';
				$self->addItem({$tag => $o_group->RemoteUser});
			}
		}
	}

	$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
