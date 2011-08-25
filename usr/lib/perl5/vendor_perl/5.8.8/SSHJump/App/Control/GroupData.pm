package SSHJump::App::Control::GroupData;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Form';

use constant DEFAULT_HEIGHT => 14;
use constant DEFAULT_WIDTH  => 70;
use constant DEFAULT_ITEMS  => 3;

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

	$self->Title('Add Group');

	$self->appendText('Enter group data.' . "\n\n" . 'Required fields ');
	$self->appendText('are marked with an asterisk(*).  Leaving any '  );
	$self->appendText('required field empty will cancel this dialog '  );
	$self->appendText('and return you to the previous menu.' . "\n\n"  );
	$self->CancelButton(1);
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->FormHeight(DEFAULT_ITEMS);

	$self->addField(['*Group Name :', 1, 1, '', 1, 15, 50, 32 ]);
	$self->addField(['Description :', 2, 1, '', 2, 15, 50, 512]);
	$self->addField(['*Remote User:', 3, 1, '', 3, 15, 50, 16 ]);
}

no Moose;

1;
