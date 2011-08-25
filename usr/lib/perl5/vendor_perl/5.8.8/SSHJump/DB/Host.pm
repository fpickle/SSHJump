package SSHJump::DB::Host;

use Moose;

extends 'SSHJump::DB';

# String Properties
has 'Customer' => ( is => 'rw', isa => 'CleanStr', default => ''  );
has 'Active'   => ( is => 'rw', isa => 'CleanStr', default => 'Y' );

has 'HostName' => (
	is      => 'rw',
	isa     => 'CleanStr',
	default => '',
	trigger => \&_loadHost
);

# List Properties
has 'Aliases'  => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

# Integer Properties
has 'HostID' => (
	is      => 'rw',
	isa     => 'Int',
	default => 0,
	trigger => \&_loadHost
);

# Public Methods
sub addHost {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->HostName) {
		$self->_error('HostName undefined.  Cannot add host');
		return 0;
	}

	$sql = 'INSERT INTO `host` (`hostname`, `customer`) VALUES (?, ?)';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->HostName, $self->Customer);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$self->{HostID} = $self->DBH->last_insert_id(undef, undef, 'host', 'id');

	$sth->finish() if($sth);
	return 1;
}

sub delHost {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->HostID) {
		$self->_error('HostID undefined.  Cannot remove host');
		return 0;
	}

	$sql = 'DELETE FROM `host` WHERE id=?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->HostID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

sub addAlias {
	my ($self, $alias) = @_;
	my ($sql, $sth);

	unless($alias) {
		$self->_error('Alias required.  Cannot add alias');
		return 0;
	}

	if($self->_doesAliasExist($alias)) {
		$self->_warning('Alias already exists.  Cannot add alias');
		return 0;
	}

	unless($self->HostID) {
		$self->_error('HostID undefined.  Cannot add alias');
		return 0;
	}

	$sql = 'INSERT INTO `host_alias` (`host_id`, `alias`) VALUES (?, ?)';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->HostID, $alias);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	push @{$self->{Aliases}}, $alias;

	$sth->finish() if($sth);
	return 1;
}

sub delAlias {
	my ($self, $alias) = @_;
	my ($sql, $sth, @old_aliases);

	unless($alias) {
		$self->_error('Alias required.  Cannot remove alias');
		return 0;
	}

	unless($self->_doesAliasExist($alias)) {
		$self->_warning('Alias does not exist.  Cannot remove alias');
		return 0;
	}

	unless($self->HostID) {
		$self->_error('HostID undefined.  Cannot remove alias');
		return 0;
	}

	$sql = 'DELETE FROM `host_alias` WHERE `host_id`=? and `alias`=?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->HostID, $alias);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	@old_aliases = @{$self->Aliases};
	$self->{Aliases} = [];

	for(my $x = 0; $x < @old_aliases; $x++) {
		unless($old_aliases[$x] eq $alias) {
			push @{$self->{Aliases}}, $old_aliases[$x];
		}
	}

	$sth->finish() if($sth);
	return 1;
}

sub updateHost {
	my ($self) = @_;
	my ($sql, $sth, @search, @params);

	unless($self->Customer || $self->Active =~ m/^N|Y$/) {
		$self->_error('Required properties undefined.  Cannot update host');
		return 0;
	}

	unless($self->HostID) {
		$self->_error('HostID undefined.  Cannot update host');
		return 0;
	}

	if($self->Customer) {
		push @search, '`customer`=?';
		push @params, $self->Customer;
	}

	if($self->Active) {
		push @search, '`active`=?';
		push @params, $self->Active;
	}

	$sql  = 'UPDATE `host` SET ';
	$sql .= join(',', @search);
	$sql .= ' WHERE `id`=?';
	
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	push @params, $self->HostID;
	$sth->execute(@params);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	$sth->finish() if($sth);
	return 1;
}

# Private Methods
sub _loadHost {
	my ($self) = @_;
	my ($sql, $sth, @values);

	unless($self->HostName || $self->HostID) {
		$self->_error('HostName/HostID undefined.  Cannot lookup host');
		return 0;
	}

	$sql  = 'SELECT * FROM `host` WHERE';

	if($self->HostName) {
		$sql .= ' `hostname` = ?';
		push @values, $self->HostName;
	}

	if($self->HostID) {
		$sql .= ' `id` = ?';
		push @values, $self->HostID;
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

		$self->{HostID} = $record->{'id'};
		$self->{HostName} = $record->{'hostname'};
		$self->Customer($record->{'customer'});
		$self->Active($record->{'active'});
		$self->_loadAliases();
	} else {
		# lookup by alias...
		return 0 unless($self->HostName);

		$sql  = 'SELECT * FROM `host`, `host_alias` ';
		$sql .= 'WHERE `host`.id = `host_alias`.host_id ';
		$sql .= 'and alias = ?';

		$sth = $self->DBH->prepare($sql);

		unless($sth) {
			$self->_error($self->DBH->errstr);
			return 0;
		}

		$sth->execute($self->HostName);

		if($sth->errstr) {
			$self->_error($sth->errstr);
			return 0;
		}

		if($sth->rows) {
			my $record = $sth->fetchrow_hashref();

			$self->{HostID} = $record->{'id'};
			$self->{HostName} = $record->{'hostname'};
			$self->Customer($record->{'customer'});
			$self->Active($record->{'active'});
			$self->_loadAliases();
		}
	}

	$sth->finish() if($sth);
	return 1;
}

sub _loadAliases {
	my ($self) = @_;
	my ($sql, $sth);

	unless($self->HostID) {
		$self->_error('HostID undefined.  Cannot lookup aliases');
		return 0;
	}

	$sql = 'SELECT `alias` FROM `host_alias` WHERE `host_id` = ?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->HostID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	while(my $record = $sth->fetchrow_hashref()) {
		push @{$self->{Aliases}}, $record->{'alias'};
	}

	$sth->finish() if($sth);
	return 1;
}

sub _doesAliasExist {
	my ($self, $alias) = @_;

	return 0 unless(@{$self->Aliases});

	foreach my $current_alias (@{$self->Aliases}) {
		return 1 if($current_alias eq $alias);
	}

	return 0;
}

no Moose;

1;
