package SSHJump::DB::Collection::SSHKey;

use Moose;
use SSHJump::DB::SSHKey;

extends 'SSHJump::DB::Collection';

# Public Methods
sub removeMember {
	my ($self, $sshkey) = @_;
	my @old_keys = @{$self->Collection};
	$self->{Collection} = [];

	for(my $x = 0; $x < @old_keys; $x++) {
		unless($old_keys[$x]->Location eq $sshkey) {
			push @{$self->{Collection}}, $old_keys[$x];
		}
	}
}

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $sql = 'SELECT `location` FROM `sshkey`';
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
		my $sshkey_obj = new SSHJump::DB::SSHKey( { DBH => $self->DBH } );

		# The SSHKey object should populate itself...
		$sshkey_obj->Location($record->{'location'});
		push @{$self->{Collection}}, $sshkey_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
