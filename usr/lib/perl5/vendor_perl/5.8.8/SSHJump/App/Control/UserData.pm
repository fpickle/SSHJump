package SSHJump::App::Control::UserData;

use Moose;
use SSHJump::DB::User;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Form';

use constant DEFAULT_HEIGHT => 20;
use constant DEFAULT_WIDTH  => 70;
use constant DEFAULT_ITEMS  => 5;

# String Properties
has 'User' => ( is      => 'rw',
                isa     => 'Str',
                default => '',
                trigger => \&_load );

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

	$self->Title('Add User');

	$self->appendText('Enter user data.' . "\n\n" . 'Required fields are '  );
	$self->appendText('marked with an asterisk(*).  Leaving any required '  );
	$self->appendText('field empty will cancel this dialog and return '     );
	$self->appendText('you to the previous menu.' . "\n\n" . 'The password ');
	$self->appendText('entered here is temporary.  The user will be '       );
	$self->appendText('required to change it on their first log in.' . "\n" );
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH) unless($self->Width);
	$self->FormHeight(DEFAULT_ITEMS);
	$self->CancelButton(1);

	$self->addField(['*Username:' , 1, 1, '', 1, 12, 50, 16 ]);
	$self->addField(['*Password:' , 2, 1, '', 2, 12, 50, 16 ]);
	$self->addField(['Real Name:' , 3, 1, '', 3, 12, 50, 64 ]);
	$self->addField(['Email    :' , 4, 1, '', 4, 12, 50, 256]);
	$self->addField(['Phone    :' , 5, 1, '', 5, 12, 50, 16 ]);
}

sub _load {
	my ($self) = @_;
	my $o_user = new SSHJump::DB::User( { DBH => $self->DBH } );

	$self->Title('Modify User');
	$self->Text('Modify data for user \Zb\Z4' . $self->User . '\Zn:' . "\n\n");

	$o_user->UserName($self->User);
	$self->cleanFields();

	if($o_user) {
		if($self->User eq $self->CurrentUser) {
			$self->Height(10);
			$self->FormHeight(3);

			$self->addField(['Real Name:', 1, 1, $o_user->RealName, 1, 12, 50, 64 ]);
			$self->addField(['Email    :', 2, 1, $o_user->Email,    2, 12, 50, 256]);
			$self->addField(['Phone    :', 3, 1, $o_user->Phone,    3, 12, 50, 16 ]);
		} else {
			$self->Height(15);
			$self->FormHeight(4);

			$self->appendText('The password entered here is temporary.');
			$self->appendText('  The user will be required to change ' );
			$self->appendText('it on their first log in.' . "\n"       );

			$self->addField(['Password :', 1, 1, '********',        1, 12, 50, 16 ]);
			$self->addField(['Real Name:', 2, 1, $o_user->RealName, 2, 12, 50, 64 ]);
			$self->addField(['Email    :', 3, 1, $o_user->Email,    3, 12, 50, 256]);
			$self->addField(['Phone    :', 4, 1, $o_user->Phone,    4, 12, 50, 16 ]);
		}
	}
}

no Moose;

1;
