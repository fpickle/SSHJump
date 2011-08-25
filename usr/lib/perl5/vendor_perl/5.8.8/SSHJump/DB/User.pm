package SSHJump::DB::User;

use Moose;

extends 'SSHJump::DB';

# Boolean Properties
has 'Exists'      => ( is => 'ro', isa => 'Bool', default => 0 );
has 'ForceChange' => ( is => 'rw', isa => 'Bool', default => 0 );

# String Properties
has 'Password' => ( is => 'rw', isa => 'CleanStr', default => ''     );
has 'RealName' => ( is => 'rw', isa => 'CleanStr', default => ''     );
has 'Email'    => ( is => 'rw', isa => 'CleanStr', default => ''     );
has 'Phone'    => ( is => 'rw', isa => 'CleanStr', default => ''     );
has 'Access'   => ( is => 'rw', isa => 'CleanStr', default => 'USER' );
has 'Active'   => ( is => 'rw', isa => 'CleanStr', default => 'Y'    );

has 'EncryptedPassword' => (
	is      => 'ro',
	isa     => 'Str',
	default => ''
);

has 'UserName' => (
	is      => 'rw',
	isa     => 'CleanStr',
	default => '',
	trigger => \&_loadUser
);

# Integer Properties
has 'UserID' => (
	is      => 'rw',
	isa     => 'Int',
	default => 0,
	trigger => \&_loadUser
);

# Public Methods
sub addUser {
	my ($self) = @_;
	my ($sql, $sth, %field_values, @fields, @values);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot add user');
		return 0;
	}

	unless($self->DBH) {
		$self->_error('Database handle required');
		return 0;
	}

	# Need a better way of doing this...maybe an ORM class for sshjump.user...
	$field_values{'username'} = $self->UserName;
	$field_values{'real_name'} = $self->RealName if($self->RealName);
	$field_values{'email'} = $self->Email        if($self->Email);
	$field_values{'phone'} = $self->Phone        if($self->Phone);
	$field_values{'access'} = $self->Access;

	# Need to make sure the order of field to value entries are synced...
	foreach my $key (sort keys %field_values) {
		push @fields, $key;
		push @values, $field_values{$key};
	}

	$sql  = 'INSERT INTO user (' . join(',', @fields) . ')';
	$sql .= ' VALUES (' . join(',', map { '?' } @values) . ')';

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

	$self->{'UserID'} = $self->DBH->last_insert_id(undef, undef, 'user', 'id');

	$sth->finish() if($sth);
	return 1;
}

sub delUser {
	my ($self) = @_;
	my ($sql, $sth, %field_values, @fields, @values);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot add user');
		return 0;
	}

	unless($self->DBH) {
		$self->_error('Database handle required');
		return 0;
	}

	$sql = 'DELETE FROM `user` WHERE `username` = ?';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->UserName);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

sub updateUser {
	my ($self) = @_;
	my ($sql, $sth, %field_values, @fields, @values);

	unless($self->UserName) {
		$self->_error('UserName undefined.  Cannot add user');
		return 0;
	}

	unless($self->DBH) {
		$self->_error('Database handle required');
		return 0;
	}

	$sql  = 'UPDATE `user` SET
	           `real_name` = ?,
	           `email` = ?,
	           `phone` = ?,
	           `access` = ?,
	           `active` = ?
	         WHERE `username` = ?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute( $self->RealName,
	               $self->Email,
	               $self->Phone,
	               $self->Access,
	               $self->Active,
	               $self->UserName );

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

# Private Methods
sub _loadUser {
	my ($self) = @_;
	my $record = {};
	my (@values);

	if($self->DBH) {
		my ($sql, $sth);
	 
		unless($self->UserName || $self->UserID) {
			$self->_error('UserName/UserID undefined.  Cannot lookup user');
			return 0;
		}

		$sql = 'SELECT * FROM `user` WHERE';

		if($self->UserName) {
			$sql .= ' `username` = ?';
			push @values, $self->UserName;
		}

		if($self->UserID) {
			$sql .= ' `id` = ?';
			push @values, $self->UserID;
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
		} else {
			if($sth->rows) {
				$self->_warning('SSHJump user ' . $self->UserName . 'already exists');
				$self->{Exists}++;

				$record = $sth->fetchrow_hashref();

				$self->{UserID} = $record->{'id'}         if($record->{'id'});
				$self->{UserName} = $record->{'username'} if($record->{'username'});
				$self->RealName($record->{'real_name'})   if($record->{'real_name'});
				$self->Email($record->{'email'})          if($record->{'email'});
				$self->Phone($record->{'phone'})          if($record->{'phone'});
				$self->Access($record->{'access'})        if($record->{'access'});
				$self->Active($record->{'active'})        if($record->{'active'});
			}
		}

		$sth->finish() if($sth);
		return 1;
	}
}

no Moose;

1;
