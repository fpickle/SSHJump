package SSHJump::DB::Collection::Host;

use Moose;
use SSHJump::DB::Host;

extends 'SSHJump::DB::Collection';

# Public Methods
sub removeMember {
	my ($self, $host) = @_;
	my @old_hosts = @{$self->Collection};
	$self->{Collection} = [];

	for(my $x = 0; $x < @old_hosts; $x++) {
		unless($old_hosts[$x]->HostName eq $host) {
			push @{$self->{Collection}}, $old_hosts[$x];
		}
	}
}

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $sql = 'SELECT `hostname` FROM `host`';
	my $sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_error($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute()) {
		$self->_error($sth->errstr);
		return 0;
	}

	while(my $record = $sth->fetchrow_hashref()) {
		my $host_obj = new SSHJump::DB::Host( { DBH => $self->DBH } );

		# The host object should populate itself...
		$host_obj->HostName($record->{'hostname'});

		push @{$self->{Collection}}, $host_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
