package SSHJump::DB::Log;

use Moose;
use IO::File;

extends 'SSHJump::DB';

# String Properties
has 'EntryTime' => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'EntryType' => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'Entry'     => ( is => 'rw', isa => 'CleanStr', default => '' );

has 'LogFile' => (
	is      => 'rw',
	isa     => 'PathStr',
	default => '',
	trigger => \&_openLogFile
);

# Integer Properties
has 'LogID'     => ( is => 'rw', isa => 'Int', default => 0 );
has 'UserID'    => ( is => 'rw', isa => 'Int', default => 0 );
has 'HostID'    => ( is => 'rw', isa => 'Int', default => 0 );
has 'SessionID' => ( is => 'rw', isa => 'Int', default => 0 );

# File Handle
has 'FH' => ( is => 'ro', isa => 'FileHandle' );

# Public Methods
sub info {
	my ($self, $message) = @_;
	$self->EntryType('INFO');
	$self->Entry($message);
	$self->_write();
}

sub warning {
	my ($self, $message) = @_;
	$self->EntryType('WARNING');
	$self->Entry($message);
	$self->_write();
}

sub error {
	my ($self, $message) = @_;
	$self->EntryType('ERROR');
	$self->Entry($message);
	$self->_write();
}

sub getUserHostFromSession {
	my ($self) = @_;
	my ($sql, $sth, $record);

	unless($self->DBH) {
		$self->_error('DBH not set');
		return 0;
	}

	unless($self->SessionID) {
		$self->_error('Session ID is required but not present');
		return 0;
	}

	$sql = 'SELECT distinct user_id, host_id FROM log WHERE session_id=?';

	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	$sth->execute($self->SessionID);

	if($sth->errstr) {
		$self->_error($sth->errstr);
		return 0;
	}

	if($record = $sth->fetchrow_hashref()) {
		$self->UserID($record->{'user_id'});
		$self->HostID($record->{'host_id'});
	}

	$sth->finish() if($sth);
	return 1;
}

# Private Methods
sub _write {
	my ($self) = @_;
	$self->_dbWrite() if($self->DBH);
	$self->_fileWrite() if($self->FH);
}

sub _dbWrite {
	my ($self) = @_;
	my ($sql, $sth, %field_values, @fields, @values);

	unless($self->DBH) {
		$self->_error('DBH not set');
		return 0;
	}

	$field_values{'user_id'} = $self->UserID;
	$field_values{'host_id'} = $self->HostID;
	$field_values{'session_id'} = $self->SessionID;
	$field_values{'entry_type'} = $self->EntryType;
	$field_values{'entry'} = $self->Entry;

	foreach my $key (sort keys %field_values) {
		push @fields, $key;
		push @values, $field_values{$key};
	}

 	$sql  = 'INSERT INTO log (' . join(',', @fields) . ') VALUES (';
  $sql .=	join(',', map { '?' } @values) . ')'; 

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

	$sth->finish() if($sth);
	return 1;
}

sub _fileWrite {
	my ($self) = @_;

	unless($self->FH) {
		$self->_error('FH not set');
		return 0;
	}

	print {$self->FH} '[' . scalar(localtime) . ']' . "\t";
	print {$self->FH} $self->UserID . "\t";
	print {$self->FH} $self->HostID . "\t";
	print {$self->FH} $self->SessionID . "\t";
	print {$self->FH} $self->EntryType . "\t";
	print {$self->FH} $self->Entry . "\n";

	return 1;
}

sub _openLogFile {
	my ($self) = @_;

	unless($self->LogFile) {
		$self->_error('LogFile not set');
		return 0;
	}

	$self->{FH} = new IO::File;

	unless($self->FH->open('>>' . $self->LogFile)) {
		$self->_error('Cannot open ' . $self->LogFile);
		return 0;
	}

	return 1;
}

sub DEMOLISH {
	my ($self) = @_;
	$self->FH->close if($self->FH);
}

no Moose;

1;
