package SSHJump::DB::SSHKey;

use Moose;

extends 'SSHJump::DB';

# String Properties
has 'Location' => (
	is      => 'rw',
	isa     => 'PathStr',
	default => '',
	trigger => \&_loadKey
);

# Integer Properties
has 'SSHKeyID'   => (
	is      => 'rw',
	isa     => 'Int',
	default => 0,
	trigger => \&_loadKey
);

# Public Methods
sub addKey {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->Location) {
		$self->_error('Location undefined.  Cannot add key');
		return 0;
	}

	$sql = 'INSERT INTO `sshkey` (`location`) VALUES (?)';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->Location);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$self->{SSHKeyID} = $self->DBH->last_insert_id(undef, undef, 'sshkey', 'id');

	$sth->finish() if($sth);
	return 1;
}

sub delKey {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->Location) {
		$self->_error('Location undefined.  Cannot remove key');
		return 0;
	}

	$sql = 'DELETE FROM `sshkey` WHERE `location`=?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->Location);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

# Private Methods
sub _loadKey {
	my ($self) = @_;
	my ($sql, $sth, @values);

	unless($self->Location || $self->SSHKeyID) {
		$self->_error('Location/SSHKeyID undefined.  Cannot lookup key');
		return 0;
	}

	$sql = 'SELECT * FROM `sshkey` WHERE';
 
	if($self->Location) {
		$sql .= ' `location` = ?';
		push @values, $self->Location;
	}

	if($self->SSHKeyID) {
		$sql .= ' `id` = ?';
		push @values, $self->SSHKeyID;
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
		$self->{SSHKeyID} = $record->{'id'};
		$self->{Location} = $record->{'location'};
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
