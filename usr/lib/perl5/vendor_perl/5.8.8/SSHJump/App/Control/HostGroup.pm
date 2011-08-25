package SSHJump::App::Control::HostGroup;

use Moose;
use SSHJump::DB::Host;
use SSHJump::DB::Collection::Group;
use SSHJump::DB::Collection::HostGroup;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::CheckList';

use constant DEFAULT_HEIGHT => 18;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 10;

# Boolean Properties
has 'Empty' => ( is => 'ro', isa => 'Bool', default => 0 );

# String Properties
has 'Host'  => ( is      => 'rw',
                 isa     => 'Str',
                 default => '',
                 trigger => \&_load );

# Database Handle
has 'DBH'   => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('Host List');
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ListHeight(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;
	my $o_host = new SSHJump::DB::Host({DBH => $self->DBH});
	my $c_group = new SSHJump::DB::Collection::Group({DBH => $self->DBH});

	$self->Text('Add or remove groups from host:' . "\n");
	$self->appendText('\Zb\Z4' . $self->Host . '\Zn');

	$o_host->HostName($self->Host);

	unless(defined $c_group->Collection) {
		$self->{Empty} = 1;
		return;
	}

	foreach my $o_group (@{$c_group->Collection}) {
		my $c_hostgroup = new SSHJump::DB::Collection::HostGroup({DBH => $self->DBH});
		my $status = 'off';

		$c_hostgroup->GroupID($o_group->GroupID);
		$status = 'on' if($c_hostgroup->isHostInGroup($o_host->HostID));

		$self->addItem([$o_group->GroupName, '', $status]);
	}
}

no Moose;

1;
