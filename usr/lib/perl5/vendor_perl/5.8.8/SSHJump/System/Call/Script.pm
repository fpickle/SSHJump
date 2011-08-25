package SSHJump::System::Call::Script;

use Moose;

use SSHJump::Utils;

extends 'SSHJump::System::Call';

# String Properties
has 'FileBase'   => ( is => 'ro', isa => 'Str', default => ''      );
has 'LogDir'     => ( is => 'rw', isa => 'CleanStr', required => 1 );
has 'User'       => ( is => 'rw', isa => 'CleanStr', required => 1 );
has 'Host'       => ( is => 'rw', isa => 'CleanStr', required => 1 );
has 'RemoteUser' => ( is => 'rw', isa => 'CleanStr', required => 1 );
has 'Key'        => ( is => 'rw', isa => 'CleanStr', required => 1 );

# Public Methods
sub execute {
	my ($self) = @_;

	return 0 unless($self->Command);
	return 0 unless($self->FileBase);

	system("clear");

	$self->Log->info('EXECUTE:  ' . $self->Command) if($self->Log);
	$self->{'ExitCode'} = system($self->_wrap()) >> 8;
}

# Private Methods
sub _wrap {
	my ($self) = @_;
	my $script_command  = '/usr/bin/script -q';
	   $script_command .= ' -c "' . $self->Command . '"';
	   $script_command .= ' -t -f ' . $self->FileBase;
	   $script_command .= '.log 2> ' .$self->FileBase . '.timing';

	return $script_command;
}

sub _prepareLogDir {
	my ($self) = @_;
	SSHJump::Utils::prepareDirectory($self->LogDir);
}

sub _generateFileBase {
	my ($self) = @_;

	$self->{FileBase}  = $self->LogDir . '/' . $self->Host . '-';
	$self->{FileBase} .= $self->User . '-' . time . '-' . $$;
}

no Moose;

1;
