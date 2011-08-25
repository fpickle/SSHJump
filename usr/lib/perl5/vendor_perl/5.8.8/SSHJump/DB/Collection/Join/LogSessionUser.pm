package SSHJump::DB::Collection::Join::LogSessionUser;

use Moose;
use SSHJump::DB::Join::LogSessionUser;

extends 'SSHJump::DB::Collection';

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($sql, $sth, @params);

	$sql = 'SELECT username,
                 real_name,
                 email,
                 phone,
                 count(*) AS sessions,
                 max(date) AS last_entry_time,
                 user_id
          FROM ( SELECT user.username,
                        user.real_name,
                        user.email,
                        user.phone,
                        session.id,
                        user.id AS user_id
                 FROM user,
                      log,
                      session
                 WHERE user.id = log.user_id AND
                       session.id = log.session_id
                 GROUP BY session.id ) AS user_sessions,
               ( SELECT session_id AS id,
                        max(entry_time) AS date
                 FROM log
                 GROUP BY session_id ) AS last_entry
          WHERE user_sessions.id = last_entry.id
          GROUP BY username';

	$sql =~ s/\s+/ /g;

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
		my $obj = new SSHJump::DB::Join::LogSessionUser({DBH => $self->DBH});

		$obj->Email($record->{'email'});
		$obj->LastEntryTime($record->{'last_entry_time'});
		$obj->Phone($record->{'phone'});
		$obj->RealName($record->{'real_name'});
		$obj->Sessions($record->{'sessions'});
		$obj->UserName($record->{'username'});
		$obj->UserID($record->{'user_id'});

		push @{$self->{Collection}}, $obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
