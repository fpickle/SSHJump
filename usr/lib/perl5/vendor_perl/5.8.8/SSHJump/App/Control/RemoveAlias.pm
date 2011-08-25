package SSHJump::App::Control::RemoveAlias;

use Moose;
use SSHJump::DB::Host;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 19;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 10;

# String Properties
has 'Host' => ( is      => 'rw',
                isa     => 'Str',
                default => '',
                trigger => \&_load );

# Database Handle
has 'DBH'  => ( is => 'rw', isa => 'Object', required => 1 ); 

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);
}

sub _load {
	my ($self) = @_;
	my $o_host = new SSHJump::DB::Host({DBH => $self->DBH});

	$self->Title('Alias List');
	$self->appendText('Choose a host \Zb\Z4' . $self->Host);
	$self->appendText('\Zn alias to delete:'              );

	$o_host->HostName($self->Host);

	if($o_host->Aliases) {
		foreach my $alias (@{$o_host->Aliases}) {
			$self->addItem( { $alias => $self->Host } );
		}
	}

	$self->addItem({'BACK' => 'Return to previous menu'});
}

no Moose;

1;
