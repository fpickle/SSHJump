package SSHJump::DB::Collection::Log;

use Moose;
use SSHJump::DB::Log;

extends 'SSHJump::DB::Collection';

# Integer Properties
has 'SessionID' => ( is => 'rw', isa => 'Str', default => 0 );

# Public Methods
sub removeMember {
	my ($self, $log_id) = @_;
	my @old_logs = @{$self->Collection};
	$self->{Collection} = [];

	for(my $x = 0; $x < @old_logs; $x++) {
		unless($old_logs[$x]->LogID eq $log_id) {
			push @{$self->{Collection}}, $old_logs[$x];
		}
	}
}

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($sql, $sth, @params);

	$sql  = 'SELECT * FROM log';

	if($self->SessionID) {
		$sql .= ' WHERE session_id=?';
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

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	while(my $record = $sth->fetchrow_hashref()) {
		my $log_obj = new SSHJump::DB::Log( { DBH => $self->DBH } );

		$log_obj->LogID($record->{'id'});
		$log_obj->UserID($record->{'user_id'});
		$log_obj->HostID($record->{'host_id'});
		$log_obj->SessionID($record->{'session_id'});
		$log_obj->EntryTime($record->{'entry_time'});
		$log_obj->EntryType($record->{'entry_type'});
		$log_obj->Entry($record->{'entry'});

		push @{$self->{Collection}}, $log_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
