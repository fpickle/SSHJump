package SSHJump::DB::Collection::HostGroup;

use Moose;
use SSHJump::DB::Group;
use SSHJump::DB::Host;

extends 'SSHJump::DB::Collection';

# If passed a HostID, this collection will contain a list
# of the group objects that contain the specified host.

# If passed a GroupID, this collection will contain a list
# of the host objects that belong to the specified group.

# String Properties
has 'Type'    => (is => 'ro', isa => 'Str', default => '');

# Integer Properties
has 'HostID'  => ( is      => 'rw',
                   isa     => 'Int',
                   default => 0,
                   trigger => \&_loadGroups );
has 'GroupID' => ( is      => 'rw',
                   isa     => 'Int',
                   default => 0,
                   trigger => \&_loadHosts );

# Public Methods
sub removeMember {
	my ($self, $name) = @_;
	my @old_objects = @{$self->Collection};
	my ($method);

	$self->{Collection} = [];

	$method = 'GroupName' if($self->Type eq 'Group');
	$method = 'HostName'  if($self->Type eq 'Host');

	unless($method) {
		$self->_error('Cannot determine object type');
		return 0;
	}

	for(my $x = 0; $x < @old_objects; $x++) {
		unless($old_objects[$x]->$method eq $name) {
			push @{$self->{Collection}}, $old_objects[$x];
		}
	}

	return 1;
}

sub isHostInGroup {
	my ($self, $host_id) = @_;

	# Only allowed if this is a collection of hosts...
	return 0 unless( ($self->Type eq 'Host') && ($self->Collection) );

	foreach my $host_obj (@{$self->Collection}) {
		return 1 if($host_obj->HostID == $host_id);
	}

	return 0;
}

sub clean {
	my ($self) = @_;
	return $self->_removeHostFromGroups() if($self->Type eq 'Group');
	return $self->_removeHostsFromGroup() if($self->Type eq 'Host');
}

# Private Methods
sub _loadGroups {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->HostID) {
		$self->_error('HostID undefined.  Cannot lookup host groups');
		return 0;
	}

	$self->{Type} = 'Group';

	$sql = 'SELECT `group_id` FROM `host_group` WHERE `host_id`=?';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute($self->HostID)) {
		$self->_error($sth->errstr);
		return 0;
	}

	while(my $record = $sth->fetchrow_hashref()) {
		my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );

		# The group object should populate itself...
		$group_obj->GroupID($record->{'group_id'});
		push @{$self->{Collection}}, $group_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

sub _loadHosts {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID) {
		$self->_error('GroupID undefined.  Cannot lookup group hosts');
		return 0;
	}

	$self->{Type} = 'Host';

	$sql = 'SELECT `host_id` FROM `host_group` WHERE `group_id`=?';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute($self->GroupID)) {
		$self->_error($sth->errstr);
		return 0;
	}

	while(my $record = $sth->fetchrow_hashref()) {
		my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );

		# The host object should populate itself...
		$host_obj->HostID($record->{'host_id'});
		push @{$self->{Collection}}, $host_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

sub _removeHostFromGroups {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->HostID) {
		$self->_error('HostID undefined.  Cannot remove host from groups');
		return 0;
	}

	$sql = 'DELETE FROM `host_group` WHERE `host_id`=?';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute($self->HostID)) {
		$self->_error($sth->errstr);
		return 0;
	}

	$self->{Collection} = [];
	$sth->finish() if($sth);
	return 1;
}

sub _removeHostsFromGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID) {
		$self->_error('GroupID undefined.  Cannot delete hosts');
		return 0;
	}

	$sql = 'DELETE FROM `host_group` WHERE `group_id`=?';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute($self->GroupID)) {
		$self->_error($sth->errstr);
		return 0;
	}

	$self->{Collection} = [];
	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
