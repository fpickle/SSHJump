package SSHJump::DB::HostGroup;

use Moose;

extends 'SSHJump::DB';

# Integer Properties
has 'GroupID' => ( is => 'rw', isa => 'Int', default => 0 );
has 'HostID'  => ( is => 'rw', isa => 'Int', default => 0 );

# Public Methods
sub addHostGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID && $self->HostID) {
		$self->_error('GroupID and/or HostID undefined.  Cannot add host-group');
		return 0;
	}

	$sql  = 'INSERT INTO `host_group` (`host_id`, `group_id`) VALUES (?, ?)';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->HostID, $self->GroupID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

sub delHostGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID && $self->HostID) {
		$self->_error('GroupID and/or HostID undefined.  Cannot remove host-group');
		return 0;
	}

	$sql = 'DELETE FROM `host_group` WHERE `group_id`=? and `host_id`=?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->GroupID, $self->HostID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
