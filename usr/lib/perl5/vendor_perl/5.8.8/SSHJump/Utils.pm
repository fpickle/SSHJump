package SSHJump::Utils;

use strict;

sub prepareDirectory {
	my ($directory, $permissions) = @_;
	my ($rv);
	
	unless( -d $directory ) {
		$rv = system('mkdir -p ' . $directory);
		return $rv if($rv);

		if($permissions) {
			$rv = system('chmod ' . $permissions . ' ' . $directory);
			return $rv if($rv);
		}
	}

	return 0;
}

sub getCurrentUser {
	my ($current_user);

	if($ENV{'SUDO_USER'}) {
		$current_user = $ENV{'SUDO_USER'};
	} elsif($ENV{'USER'}) {
		$current_user = $ENV{'USER'};
	} elsif($ENV{'USERNAME'}) {
		$current_user = $ENV{'USERNAME'};
	}

	return $current_user;
}

1;
