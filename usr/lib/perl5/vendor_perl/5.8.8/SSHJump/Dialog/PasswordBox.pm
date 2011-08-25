package SSHJump::Dialog::PasswordBox;

use Moose;

extends 'SSHJump::Dialog';

# Integer Properties
has 'Insecure' => ( is => 'rw', isa => 'Int', default => 1 );

sub render {
	my ($self) = @_;
	my $rv = 0;
	my $command = $self->Command;

	$command .= ' --clear'    if($self->Clear);
	$command .= ' --colors'   if($self->Colors);
	$command .= ' --cr-wrap'  if($self->CrWrap);
	$command .= ' --insecure' if($self->Insecure);
	$command .= ' --ignore'   if($self->Ignore);

	$command .= " --title '" . $self->Title . "'";
	$command .= " --sleep '" . $self->Sleep if($self->Sleep);

	# standard dialogs accept text, height, width args...
	$command .= " --passwordbox '" . $self->Text . "'";
	$command .= ' ' . $self->Height;
	$command .= ' ' . $self->Width;

	$command .= ' 2> ' . $self->TempFile;

	$self->_xlateExitCode(system($command));
}

1;
