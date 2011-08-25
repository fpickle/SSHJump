package SSHJump::App::Control::Info;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog';

use constant DEFAULT_HEIGHT => 5;
use constant DEFAULT_WIDTH  => 50;

# Integer Properties
has 'Sleep' => ( is => 'rw', isa => 'Int', default => 0 );

# Public Methods
sub show {
	my ($self) = @_;
	$self->render();
	sleep($self->Sleep);
}

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Type('infobox');
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	sleep($self->Sleep);
}

no Moose;

1;
