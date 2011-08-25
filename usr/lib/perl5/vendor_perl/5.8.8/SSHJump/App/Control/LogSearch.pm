package SSHJump::App::Control::LogSearch;

use Moose;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Form';

use constant DEFAULT_HEIGHT => 18;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 5;

# List Properties
has 'Data' => ( is => 'ro', isa => 'ArrayRef' );

# Database Handle
has 'DBH'  => ( is => 'rw', isa => 'Object', required => 1 );

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

	$self->Title('Log Search');

	$self->Text( 'Leave this form blank to list all session logs.' . "\n\n" );
	$self->appendText( 'Enter search parameters into the correct form '     );
	$self->appendText( 'fields to find the log(s) you wish to view.'        );
	$self->appendText( "\n\n" . 'All dates should follow the form '         );
	$self->appendText( '\Zb\Z4YYYY-MM-DD HH:MM:SS\Zn.'                      );
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH) unless($self->Width);
	$self->FormHeight(DEFAULT_ITEMS);
	$self->CancelButton(1);

	$self->addField(['User       :' , 1, 1, '', 1, 12, 50, 16  ]);
	$self->addField(['Host       :' , 2, 1, '', 2, 12, 50, 128 ]);
	$self->addField(['Log File   :' , 3, 1, '', 3, 12, 50, 256 ]);
	$self->addField(['Start Date :' , 4, 1, '', 4, 12, 50, 20  ]);
	$self->addField(['End Date   :' , 5, 1, '', 5, 12, 50, 20  ]);
}

no Moose;

1;
