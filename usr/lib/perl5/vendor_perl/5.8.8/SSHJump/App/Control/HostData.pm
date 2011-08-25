package SSHJump::App::Control::HostData;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Form';

use constant DEFAULT_HEIGHT => 17;
use constant DEFAULT_WIDTH  => 70;

# List Properties
has 'Data' => ( is => 'ro', isa => 'ArrayRef' );

# Public Methods
sub show {
	my ($self) = @_;
	$self->render();

	if( ($self->ExitMsg eq 'ESC') && ($self->EscapeHandler) ) {
		&{$self->EscapeHandler};
	}

	@{$self->{Data}} = $self->getData();
}

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title('Add Host');

	$self->appendText('Enter host data.' . "\n\n" . 'Required fields ' );
	$self->appendText('are marked with an asterisk(*).  Leaving any '  );
	$self->appendText('required field empty will cancel this dialog '  );
	$self->appendText('and return you to the previous menu.' . "\n\n"  );
	$self->appendText('List all host aliases (comma seperated).' . "\n");
	$self->CancelButton(1);
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);

	$self->addField(['*Host Name:', 1, 1, '', 1, 12, 50, 128]);
	$self->addField(['*Customer :', 2, 1, '', 2, 12, 50, 64 ]);
	$self->addField(['Aliases   :', 3, 1, '', 3, 12, 50, 256]);
}

no Moose;

1;
