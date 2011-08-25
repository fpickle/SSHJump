package SSHJump::DB::Session;

use Moose;
use IO::File;

extends 'SSHJump::DB';

# String Properties
has 'Reason'     => ( is => 'rw', isa => 'CleanStr', default => ''     );
has 'Status'     => ( is => 'rw', isa => 'CleanStr', default => 'OPEN' );
has 'Type'       => ( is => 'rw', isa => 'CleanStr', default => 'CMD'  );
has 'TimeOpened' => ( is => 'rw', isa => 'CleanStr', default => ''     );
has 'TimeClosed' => ( is => 'rw', isa => 'CleanStr', default => ''     );
has 'LogFile'    => ( is => 'rw', isa => 'PathStr', default => ''      );

# Integer Properties
has 'SessionID' => ( is => 'rw', isa => 'Int', default => 0 );

# Public Methods
sub open {
  my ($self) = @_;
  my $sql  = 'INSERT INTO session (status, reason, type, time_opened)';
     $sql .= '  values (?, ?, ?, NOW())';
  my ($sth);

  unless($self->DBH) {
    $self->_error('DBH not set');
    return 0;
  }  

  $sth = $self->DBH->prepare($sql);

  unless($sth) {
    $self->_error($self->DBH->errstr);
    return 0;
  }

  $sth->execute($self->Status, $self->Reason, $self->Type);

  if($sth->errstr) {
    $self->_error($sth->errstr);
    return 0;
  }

  $self->{SessionID} = $self->DBH->last_insert_id( undef,
                                                   undef,
                                                   'session',
                                                   'id' );

  $sth->finish() if($sth);
  return 1;
}

sub getSessionFromLogFile {
  my ($self) = @_;
  my $sql = 'SELECT * FROM session WHERE log_file = ?';
  my ($sth, $record);

  unless($self->LogFile) {
    $self->_error('LogFile not set');
    return 0;
  }

  unless($self->DBH) {
    $self->_error('DBH not set');
    return 0;
  }  

  $sth = $self->DBH->prepare($sql);

  unless($sth) {
    $self->_error($self->DBH->errstr);
    return 0;
  }

  $sth->execute($self->LogFile);

  if($sth->errstr) {
    $self->_error($sth->errstr);
    return 0;
  }

  $record = $sth->fetchrow_hashref();

  if((defined $record->{'id'}) && ($record->{'id'} =~ m/^\d+/)) {
    $self->SessionID($record->{'id'});
    $self->Reason($record->{'reason'});
    $self->Status($record->{'status'});
    $self->Type($record->{'type'});
    $self->TimeOpened($record->{'time_opened'});
    $self->TimeClosed($record->{'time_closed'});
  }

  $sth->finish() if($sth);
  return 1;
}

sub getSessionFromID {
  my ($self) = @_;
  my $sql = 'SELECT * FROM session WHERE id = ?';
  my ($sth, $record);

  unless($self->SessionID) {
    $self->_error('SessionID not set');
    return 0;
  }

  unless($self->DBH) {
    $self->_error('DBH not set');
    return 0;
  }  

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

  $record = $sth->fetchrow_hashref();

  if($sth->rows() == 1) {
    $self->LogFile($record->{'log_file'});
    $self->Reason($record->{'reason'});
    $self->Status($record->{'status'});
    $self->Type($record->{'type'});
    $self->TimeOpened($record->{'time_opened'});
    $self->TimeClosed($record->{'time_closed'});
  }

  $sth->finish() if($sth);
  return 1;
}

sub close { 
  my ($self) = @_;
  my $sql  = 'UPDATE session set status=?, log_file=?, time_closed=NOW() WHERE id=?';
  my ($sth);

  unless($self->DBH) {
    $self->_error('DBH not set');
    return 0;
  }  

  $sth = $self->DBH->prepare($sql);

  unless($sth) {
    $self->_error($self->DBH->errstr);
    return 0;
  }

  $self->Status('CLOSED');

  $sth->execute($self->Status, $self->LogFile, $self->SessionID);

  if($sth->errstr) {
    $self->_error($sth->errstr);
    return 0;
  }

  $sth->finish() if($sth);
  return 1;
}

no Moose;

1;
