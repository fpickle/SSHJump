package SSHJump::DB::Collection::Join::HostLogUser;

use Moose;
use SSHJump::DB::Join::HostLogUser;

extends 'SSHJump::DB::Collection';

# Integer Properties
has 'SessionID' => ( is => 'rw', isa => 'Str', default => 0 );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($sql, $sth, @params);

	$sql = 'SELECT log.id as log_id,
                 user.username,
                 host.hostname,
                 log.entry_type,
                 log.entry_time,
                 log.entry
          FROM user,
               host,
               log
          WHERE user.id = log.user_id and
                host.id = log.host_id';

	$sql =~ s/\s+/ /g;

	if($self->SessionID) {
		$sql .= ' and log.session_id = ?';
		push @params, $self->SessionID;
	}

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	if(@params) {
		$sth->execute(@params);
	} else {
		$sth->execute();
	}

	if($sth->errstr()) {
		$self->_error($sth->errstr);
		return 0;
	}

	while(my $record = $sth->fetchrow_hashref()) {
		my $obj = new SSHJump::DB::Join::HostLogUser({DBH => $self->DBH});

		$obj->HostName($record->{'hostname'});
		$obj->EntryType($record->{'entry_type'});
		$obj->EntryTime($record->{'entry_time'});
		$obj->Entry($record->{'entry'});
		$obj->LogID($record->{'log_id'});
		$obj->UserName($record->{'username'});

		push @{$self->{Collection}}, $obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
