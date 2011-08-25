package SSHJump::DB::Collection::Session;

use Moose;
use SSHJump::DB::Session;

extends 'SSHJump::DB::Collection';

# String Properties
has 'Status'     => ( is => 'rw', isa => 'Str', default => '' );
has 'Type'       => ( is => 'rw', isa => 'Str', default => '' );
has 'TimeOpened' => ( is => 'rw', isa => 'Str', default => '' );

# Public Methods
sub removeMember {
	my ($self, $session_id) = @_;
	my @old_sessions = @{$self->Collection};
	$self->{Collection} = [];

	for(my $x = 0; $x < @old_sessions; $x++) {
		unless($old_sessions[$x]->SessionID eq $session_id) {
			push @{$self->{Collection}}, $old_sessions[$x];
		}
	}
}

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($sql, $sth, @params);

	$sql = 'SELECT * FROM session';

	if($self->Status || $self->Type || $self->TimeOpened) {
		my $params = 0;

		$params++ if($self->Status);
		$params++ if($self->Type);
		$params++ if($self->TimeOpened);

		$sql .= ' WHERE ';

		if($self->Status) {
			$params--;
			$sql .= ' status = ?';
			$sql .= ' and' if($params);
			push @params, $self->Status;
		}

		if($self->Type) {
			$params--;
			$sql .= ' type = ?';
			$sql .= ' and' if($params);
			push @params, $self->Type;
		}

		if($self->TimeOpened) {
			$sql .= ' time_opened < ?';
			push @params, $self->TimeOpened;
		}
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
		my $session_obj = new SSHJump::DB::Session( { DBH => $self->DBH } );

		$session_obj->Reason($record->{'reason'});
		$session_obj->SessionID($record->{'id'});
		$session_obj->Status($record->{'status'});
		$session_obj->Type($record->{'type'});
		$session_obj->TimeOpened($record->{'time_opened'});
		$session_obj->TimeClosed($record->{'time_closed'});

		push @{$self->{Collection}}, $session_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
