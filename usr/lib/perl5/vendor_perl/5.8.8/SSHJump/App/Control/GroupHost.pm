package SSHJump::App::Control::GroupHost;

use Moose;
use SSHJump::DB::Group;
use SSHJump::DB::Collection::Host;
use SSHJump::DB::Collection::HostGroup;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::CheckList';

use constant DEFAULT_HEIGHT => 18;
use constant DEFAULT_WIDTH  => 50;
use constant DEFAULT_ITEMS  => 10;

# Boolean Properties
has 'Empty' => ( is => 'ro', isa => 'Bool', default => 0 );

# String Properties
has 'Group' => ( is      => 'rw',
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
	my $o_group = new SSHJump::DB::Group({DBH => $self->DBH});
	my $c_host = new SSHJump::DB::Collection::Host({DBH => $self->DBH});
	my $c_hostgroup = new SSHJump::DB::Collection::HostGroup({DBH => $self->DBH});
	my $count = 0;

	$self->Text('Add or remove hosts from group \Zb\Z4' . $self->Group . '\Zn:');

	$o_group->GroupName($self->Group);
	$c_hostgroup->GroupID($o_group->GroupID);

	foreach my $o_host (@{$c_host->Collection}) {
		my $status = 'off';

		next if($o_host->Active eq 'N');
		$status = 'on' if($c_hostgroup->isHostInGroup($o_host->HostID));

		$self->addItem([$o_host->HostName, '', $status]);
		$count++;
	}

	$self->{Empty} = 1 unless($count);
}

no Moose;

1;
