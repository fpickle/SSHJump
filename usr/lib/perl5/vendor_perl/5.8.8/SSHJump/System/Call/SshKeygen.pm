package SSHJump::System::Call::SshKeygen;

use Moose;

extends 'SSHJump::System::Call';

# String Properties
has 'KeyName'    => ( is => 'rw', isa => 'CleanStr', required => 1    );
has 'KeyDir'     => ( is => 'rw', isa => 'PathStr', required => 1     );
has 'Type'       => ( is => 'rw', isa => 'CleanStr', default => 'rsa' );
has 'Passphrase' => ( is => 'rw', isa => 'CleanStr', default => ''    );

# Integer Properties
has 'Size'    => ( is => 'rw', isa => 'Int', default => 4096 );

# Public Methods

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Command'}  = '/usr/bin/ssh-keygen';
	$self->{'Command'} .= ' -t ' . $self->Type;
	$self->{'Command'} .= ' -b ' . $self->Size;
	$self->{'Command'} .= ' -f ' . $self->KeyDir . '/' . $self->KeyName;
	$self->{'Command'} .= " -N '" . $self->Passphrase . "'";
	$self->{'Command'} .= ' -q';

	$self->execute();
}

no Moose;

1;
