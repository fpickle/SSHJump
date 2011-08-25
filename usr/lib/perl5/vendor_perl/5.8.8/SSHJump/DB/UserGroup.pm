package SSHJump::DB::UserGroup;

use Moose;

extends 'SSHJump::DB';

# Integer Properties
has 'GroupID' => ( is => 'rw', isa => 'Int', default => 0 );
has 'UserID'  => ( is => 'rw', isa => 'Int', default => 0 );

# Public Methods
sub addUserGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID && $self->UserID) {
		$self->_error('GroupID and/or UserID undefined.  Cannot add user-group');
		return 0;
	}

	$sql  = 'INSERT INTO `user_group` (`user_id`, `group_id`) VALUES (?, ?)';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->UserID, $self->GroupID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

sub delUserGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID && $self->UserID) {
		$self->_error('GroupID and/or UserID undefined.  Cannot remove user-group');
		return 0;
	}

	$sql = 'DELETE FROM `user_group` WHERE `group_id`=? and `user_id`=?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->GroupID, $self->UserID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
