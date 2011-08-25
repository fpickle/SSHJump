package SSHJump::DB::Collection::Group;

use Moose;
use SSHJump::DB::Group;

extends 'SSHJump::DB::Collection';

# Public Methods
sub removeMember {
	my ($self, $group) = @_;
	my @old_groups = @{$self->Collection};
	$self->{Collection} = [];

	for(my $x = 0; $x < @old_groups; $x++) {
		unless($old_groups[$x]->GroupName eq $group) {
			push @{$self->{Collection}}, $old_groups[$x];
		}
	}
}

# Private Methods
sub BUILD {
	my ($self) = @_;
	my $sql = 'SELECT `groupname` FROM `group`';
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
		my $group_obj = new SSHJump::DB::Group( { DBH => $self->DBH } );

		# The group object should populate itself...
		$group_obj->GroupName($record->{'groupname'});

		push @{$self->{Collection}}, $group_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
