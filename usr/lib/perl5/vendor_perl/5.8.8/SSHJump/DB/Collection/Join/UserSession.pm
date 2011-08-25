package SSHJump::DB::Collection::Join::UserSession;

use Moose;
use SSHJump::DB::Join::UserSession;

extends 'SSHJump::DB::Collection';

# String Properties
has 'Status' => ( is => 'rw', isa => 'Str', default => '' );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($sql, $sth, @params);

	$sql  = 'SELECT distinct(username),status,type,time_closed,time_opened,';
	$sql .= 'session.id FROM user, session, log WHERE ';
	$sql .= '`session`.id = `log`.session_id and ';
	$sql .= '`log`.user_id = `user`.id';

	if($self->Status) {
		$sql .= ' and `session`.status = ?';
		push @params, $self->Status;
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
		my $obj = new SSHJump::DB::Join::UserSession({DBH => $self->DBH});

		$obj->SessionID($record->{'id'});
		$obj->UserName($record->{'username'});
		$obj->Status($record->{'status'});
		$obj->Type($record->{'type'});
		$obj->TimeOpened($record->{'time_opened'});
		$obj->TimeClosed($record->{'time_closed'});

		push @{$self->{Collection}}, $obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
