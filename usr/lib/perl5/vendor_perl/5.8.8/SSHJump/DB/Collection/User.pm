package SSHJump::DB::Collection::User;

use Moose;
use SSHJump::DB::User;

extends 'SSHJump::DB::Collection';

# Public Methods
sub removeUser {
	my ($self, $user) = @_;
	my @old_users = @{$self->Collection};
	$self->{Collection} = [];

	for(my $x = 0; $x < @old_users; $x++) {
		unless($old_users[$x]->UserName eq $user) {
			push @{$self->{Collection}}, $old_users[$x];
		}
	}
}

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($sql, $sth);

	$sql = 'SELECT `id` FROM `user`';
	$sth = $self->DBH->prepare($sql);

	unless($sth) {
		$self->_errors($self->DBH->errstr);
		return 0;
	}

	unless($sth->execute()) {
		$self->_errors($self->errstr);
		return 0;
	}

	while(my $record = $sth->fetchrow_hashref()) {
		my $user_obj = new SSHJump::DB::User( { DBH => $self->DBH } );

		# Should auto populate...
		$user_obj->UserID($record->{'id'});
		push @{$self->{Collection}}, $user_obj;
	}

	$sth->finish() if($sth);
	return 1;
}

no Moose;

1;
