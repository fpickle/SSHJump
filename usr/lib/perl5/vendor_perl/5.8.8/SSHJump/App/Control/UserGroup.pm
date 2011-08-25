package SSHJump::App::Control::UserGroup;

use Moose;
use SSHJump::App::Control::Message;
use SSHJump::DB::User;
use SSHJump::DB::Collection::Group;
use SSHJump::DB::Collection::UserGroup;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::CheckList';

use constant DEFAULT_HEIGHT => 18;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 10;

# Boolean Properties
has 'Empty' => ( is => 'ro', isa => 'Bool', default => 0 );

# String Properties
has 'User'  => ( is      => 'rw',
                 isa     => 'Str',
                 default => '',
                 trigger => \&_load );

# Database Handle
has 'DBH'   => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('Group List');
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ListHeight(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;
	my $o_user = new SSHJump::DB::User({DBH => $self->DBH});
	my $c_group = new SSHJump::DB::Collection::Group({DBH => $self->DBH});
	my $c_usergroup = new SSHJump::DB::Collection::UserGroup({DBH => $self->DBH});
	my $message = new SSHJump::App::Control::Message({ Config => $self->Config});

	$o_user->UserName($self->User);
	$c_usergroup->UserID($o_user->UserID);

	$self->Text('Choose group access for account \Zb\Z4' . $self->User . '\Zn:');

	unless(defined $c_group->Collection) {
		$self->{Empty} = 1;
		return;
	}

	foreach my $o_group (@{$c_group->Collection}) {
		my $status = 'off';

		if($c_usergroup->Collection) {
			foreach my $o_usergroup (@{$c_usergroup->Collection}) {
				$status = 'on' if($o_usergroup->GroupID == $o_group->GroupID);
			}
		}

		$self->addItem([$o_group->GroupName, '', $status]);
	}
}

no Moose;

1;
