package SSHJump::App::Control::SSHKeySelect;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog';

use constant DEFAULT_HEIGHT => 15;
use constant DEFAULT_WIDTH  => 50;

# String Properties
has 'Directory' => ( is      => 'rw',
                     isa     => 'Str',
                     default => '',
                     trigger => \&_load );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('SSH Key Registration');
	$self->Type('fselect');
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->CancelButton(1);
	$self->OKButton(1);
}

sub _load {
	my ($self) = @_;
	$self->Text($self->Directory . '/');
}

no Moose;

1;
