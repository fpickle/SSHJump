package SSHJump::DB::Group;

use Moose;

extends 'SSHJump::DB';

# String Properties
has 'Description' => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'RemoteUser'  => ( is => 'rw', isa => 'CleanStr', default => '' );

has 'GroupName' => (
	is      => 'rw',
	isa     => 'CleanStr',
	default => '',
	trigger => \&_loadGroup
);

# Integer Properties
has 'SSHKeyID' => ( is => 'rw', isa => 'Int', default => 0 );

has 'GroupID' => (
	is      => 'rw',
	isa     => 'Int',
	default => 0,
	trigger => \&_loadGroup
);

# Public Methods
sub addGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupName) {
		$self->_error('GroupName undefined.  Cannot add group');
		return 0;
	}

	$sql  = 'INSERT INTO `group`';
	$sql .= ' (`groupname`, `description`, `remote_user`, `sshkey_id`)';
	$sql .= ' VALUES (?, ?, ?, ?)';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute( $self->GroupName,
	               $self->Description,
	               $self->RemoteUser,
	               $self->SSHKeyID );

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$self->{GroupID} = $self->DBH->last_insert_id(undef, undef, 'group', 'id');

	$sth->finish() if($sth);
	return 1;
}

sub delGroup {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->GroupID) {
		$self->_error('GroupID undefined.  Cannot remove group');
		return 0;
	}

	$sql = 'DELETE FROM `group` WHERE `id`=?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->GroupID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

# Private Methods
sub _loadGroup {
	my ($self) = @_;
	my ($sql, $sth, @values);

	unless($self->GroupName || $self->GroupID) {
		$self->_error('GroupName/GroupID undefined.  Cannot lookup group');
		return 0;
	}

	$sql = 'SELECT * FROM `group` WHERE';

	if($self->GroupName) {
		$sql .= ' `groupname` = ?';
		push @values, $self->GroupName;
	}

	if($self->GroupID) {
		$sql .= ' `id` = ?';
		push @values, $self->GroupID;
	}

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute(@values);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	# Should only be one record because of the UNIQUE constraint...
	if($sth->rows) {
		my $record = $sth->fetchrow_hashref();

		$self->{GroupID} = $record->{'id'};
		$self->{GroupName} = $record->{'groupname'};
		$self->Description($record->{'description'});
		$self->RemoteUser($record->{'remote_user'});
		$self->SSHKeyID($record->{'sshkey_id'});
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
