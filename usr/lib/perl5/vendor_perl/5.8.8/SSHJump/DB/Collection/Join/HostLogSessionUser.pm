package SSHJump::DB::Collection::Join::HostLogSessionUser;

use Moose;
use SSHJump::DB::Join::HostLogSessionUser;

extends 'SSHJump::DB::Collection';

# String Properties
has 'HostName'          => ( is => 'rw', isa => 'Str', default => '' );
has 'LogFile'           => ( is => 'rw', isa => 'Str', default => '' );
has 'Status'            => ( is => 'rw', isa => 'Str', default => '' );
has 'TimeClosed'        => ( is => 'rw', isa => 'Str', default => '' );
has 'TimeOpened'        => ( is => 'rw', isa => 'Str', default => '' );
has 'Type'              => ( is => 'rw', isa => 'Str', default => '' );
has 'UserName'          => ( is => 'rw', isa => 'Str', default => '' );

# Integer Properties
has 'UserID'            => ( is => 'rw', isa => 'Int', default => 0 );
has 'LogFileIsNotEmpty' => ( is => 'rw', isa => 'Str', default => 0 );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($sql, $sth, @params);

	$sql = 'SELECT user.username,
                 session.reason,
                 session.status,
                 session.type,
                 session.time_closed,
                 session.time_opened,
                 session.log_file,
                 host.hostname,
                 session.id as session_id,
                 log.id as log_id,
                 log.entry
          FROM (SELECT session_id as id,
                       max(id) as log_id
                FROM log
                GROUP BY session_id) as temp,
                user,
                session,
                log,
                host
          WHERE session.id = temp.id and
                log.id = temp.log_id and
                log.host_id = host.id and
                log.user_id = user.id';

	$sql =~ s/\s+/ /g;

	if($self->HostName) {
		$sql .= ' and host.hostname = ?';
		push @params, $self->HostName;
	}

	if($self->LogFile) {
		$sql .= " and session.log_file like ?";
		push @params, '%' . $self->LogFile . '%';
	}

	if($self->LogFileIsNotEmpty) {
		$sql .= " and session.log_file != ''";
	}

	if($self->Status) {
		$sql .= ' and session.status = ?';
		push @params, $self->Status;
	}

	if($self->TimeClosed) {
		$sql .= ' and session.time_closed <= ?';
		push @params, $self->TimeClosed;
	}

	if($self->TimeOpened) {
		$sql .= ' and session.time_opened >= ?';
		push @params, $self->TimeOpened;
	}

	if($self->Type) {
		$sql .= ' and session.type = ?';
		push @params, $self->Type;
	}

	if($self->UserID) {
		$sql .= ' and log.user_id = ?';
		push @params, $self->UserID;
	}

	if($self->UserName) {
		$sql .= ' and user.username = ?';
		push @params, $self->UserName;
	}

	$sql .= ' ORDER BY session.time_opened DESC';
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
		my $obj = new SSHJump::DB::Join::HostLogSessionUser({DBH => $self->DBH});

		$obj->HostName($record->{'hostname'});
		$obj->LastEntry($record->{'entry'});
		$obj->LogFile($record->{'log_file'});
		$obj->LogID($record->{'log_id'});
		$obj->Reason($record->{'reason'});
		$obj->SessionID($record->{'session_id'});
		$obj->Status($record->{'status'});
		$obj->TimeClosed($record->{'time_closed'});
		$obj->TimeOpened($record->{'time_opened'});
		$obj->Type($record->{'type'});
		$obj->UserName($record->{'username'});

		push @{$self->{Collection}}, $obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
