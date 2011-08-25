package SSHJump::App::Verify;

use Moose;

use SSHJump::Dialog;

# String Properties
has 'Error'       => ( is => 'ro', isa => 'Str', default => ''      );
has 'Description' => ( is => 'rw', isa => 'CleanStr', default => '' );

# Boolean Properties
has 'Verified'    => ( is => 'ro', isa => 'Bool', default => 0 );

# Public Methods
sub renderError {
	my ($self) = @_;

	if($self->Error) {
		my $o_message = new SSHJump::Dialog();

		$o_message->Title('ERROR');
		$o_message->Type('msgbox');
		$o_message->Height(10);
		$o_message->Width(50);
		$o_message->Text($self->Error);
		$o_message->render();
	}
}

no Moose;

1;
