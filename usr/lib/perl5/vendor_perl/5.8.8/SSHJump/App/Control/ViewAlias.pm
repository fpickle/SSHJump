package SSHJump::App::Control::ViewAlias;

use Moose;
use SSHJump::DB::Host;

extends 'SSHJump::App::Control', 'SSHJump::Dialog';

use constant DEFAULT_HEIGHT => 10;
use constant DEFAULT_WIDTH  => 50;

# String Properties
has 'Host' => ( is      => 'rw',
                isa     => 'Str',
                default => '',
                trigger => \&_load );

# Database Handle
has 'DBH'  => (is => 'rw', isa => 'Object', required => 1); 

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Type('msgbox');
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
}

sub _load {
	my ($self) = @_;
	my $o_host = new SSHJump::DB::Host({DBH => $self->DBH});

	$o_host->HostName($self->Host);

	$self->Title($self->Host . ' Aliases');

	if($o_host->Aliases) {
		foreach my $alias (@{$o_host->Aliases}) {
			$self->appendText($alias . "\n");
		}
	}
}

no Moose;

1;
