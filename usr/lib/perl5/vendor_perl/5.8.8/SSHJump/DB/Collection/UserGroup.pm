package SSHJump::DB::Collection::UserGroup;

use Moose;
use SSHJump::DB::User;
use SSHJump::DB::Group;

extends 'SSHJump::DB::Collection';

# If passed a UserID, this collection will contain a list
# of the group objects that contain the specified user.

# If passed a GroupID, this collection will contain a list
# of the user objects that belong to the specified group.

# String Properties
has 'Type'    => (is => 'ro', isa => 'Str', default => '');

# Integer Properties
has 'UserID'  => ( is      => 'rw',
                   isa     => 'Int',
                   default => 0,
                   trigger => \&_loadGroups );
has 'GroupID' => ( is      => 'rw',
                   isa     => 'Int',
                   default => 0,
                   trigger => \&_loadUsers );

# Public Methods
sub removeMember {
	my ($self, $name) = @_;
	my @old_objects = @{$self->Collection};
	my ($method);

	$self->{Collection} = [];

	$method = 'GroupName' if($self->Type eq 'Group');
	$method = 'UserName'  if($self->Type eq 'User');

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

sub isUserInGroup {
	my ($self, $user_id) = @_;

	# Only allowed if this is a collection of users...
	return 0 unless( ($self->Type eq 'User') && ($self->Collection) );

	foreach my $user_obj (@{$self->Collection}) {
		return 1 if($user_obj->UserID == $user_id);
	}

	return 0;
}

sub clean {
	my ($self) = @_;
	return $self->_removeUserFromGroups() if($self->Type eq 'Group');
	return $self->_removeUsersFromGroup() if($self->Type eq 'User');
}

# Private Methods
sub _loadGroups {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->UserID) {
		$self->_error('UserID undefined.  Cannot lookup user groups');
		return 0;
	}

	$self->{Type} = 'Group';

	$sql = 'SELECT `group_id` FROM `user_group` WHERE `user_id`=?';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute($self->UserID)) {
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

sub _loadUsers {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID) {
		$self->_error('GroupID undefined.  Cannot lookup group users');
		return 0;
	}

	$self->{Type} = 'User';

	$sql = 'SELECT `user_id` FROM `user_group` WHERE `group_id`=?';
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
		my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );

		# The host object should populate itself...
		$user_obj->UserID($record->{'user_id'});
		push @{$self->{Collection}}, $user_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

sub _removeUserFromGroups {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->UserID) {
		$self->_error('UserID undefined.  Cannot delete users');
		return 0;
	}

	$sql = 'DELETE FROM `user_group` WHERE `user_id`=?';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute($self->UserID)) {
		$self->_error($sth->errstr);
		return 0;
	}

	$self->{Collection} = [];
	$sth->finish() if($sth);
	return 1;
}

sub _removeUsersFromGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID) {
		$self->_error('GroupID undefined.  Cannot delete users');
		return 0;
	}

	$sql = 'DELETE FROM `user_group` WHERE `group_id`=?';
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
