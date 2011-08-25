package SSHJump::System::Call::Sudo;

use Moose;

extends 'SSHJump::System::Call';

# String Properties
has 'User'              => ( is => 'rw', isa => 'CleanStr', required => 1 );
has 'Password'          => ( is => 'rw', isa => 'CleanStr', default => '' );
has 'EncryptedPassword' => ( is => 'ro', isa => 'Str', default => ''      );

# Public Methods
sub execute {
	my ($self) = @_;

	return 0 unless($self->Command);

	$self->Log->info('EXECUTE:  ' . $self->Command) if($self->Log);
	$self->{'ExitCode'} = system($self->_wrap()) >> 8;

	if(exists $self->{'EXIT_CODES'}) {
		$self->{'ExitMessage'} = $self->EXIT_CODES->{$self->ExitCode};
	}
}

# Private Methods
sub _wrap {
	my ($self) = @_;
	my $sudo_command  = '/usr/bin/sudo ' . $self->Command;
	system("clear");
	print $sudo_command . "\n";
	
	return $sudo_command;
}

sub _encryptPassword {
	my ($self) = @_;
	my @chars = ("A" .. "Z", "a" .. "z", 0 .. 9, qw(. /) );
	my $salt = join('', @chars[ map { rand @chars } ( 1 .. 8 ) ]);
	$self->{EncryptedPassword} = crypt($self->Password, '$1$' . $salt);
}

no Moose;

1;
