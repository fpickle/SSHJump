package SSHJump::System::Call::Script::SCP;

use Moose;

extends 'SSHJump::System::Call::Script';

# Properties
has 'From' => ( is => 'rw', isa => 'CleanStr', required => 1 );
has 'To'   => ( is => 'rw', isa => 'CleanStr', required => 1 );

# Public Methods

# Private Methods
sub BUILD {
	my ($self)      = @_;
	my $host        = $self->Host;
	my $remote_user = $self->RemoteUser;

	$self->{From} =~ s/^[^:]+/$remote_user\@$host/ if($self->From =~ m/^[^:]+:/);
	$self->{To}   =~ s/^[^:]+/$remote_user\@$host/ if($self->To   =~ m/^[^:]+:/);

	$self->_prepareLogDir();
	$self->_generateFileBase();

	$self->{Command}  = '/usr/bin/scp -C -i ' . "'" . $self->Key . "'";
	$self->{Command} .= ' -r ' . $self->From . ' ' . $self->To;
}

no Moose;

1;
