package SSHJump::Dialog::Menu;

use Moose;

extends 'SSHJump::Dialog';

# Integer Properties
has 'ItemsShown' => ( is => 'rw', isa => 'Int', default => 3 );

# Array Properties...should probably be another object
has 'Items'      => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

sub addItem {
	my ($self, $item_data) = @_;
	push @{$self->{Items}}, $item_data;
}

sub render {
	my ($self) = @_;
	my $rv = 0;
	my $command = $self->Command;

	$command .= ' --clear'   if($self->Clear);
	$command .= ' --colors'  if($self->Colors);
	$command .= ' --cr-wrap' if($self->CrWrap);
	$command .= ' --ignore'  if($self->Ignore);

	if($self->CancelLabel) {
		$self->CancelButton(1);
		$command .= " --cancel-label '" . $self->CancelLabel . "'";
	}

	$command .= ' --no-cancel' unless($self->CancelButton);

	$command .= " --title '" . $self->Title . "'";
	$command .= " --sleep '" . $self->Sleep if($self->Sleep);

	# standard dialogs accept text, height, width args...
	$command .= " --menu '" . $self->Text . "'";
	$command .= ' ' . $self->Height;
	$command .= ' ' . $self->Width;
	$command .= ' ' . $self->ItemsShown;

	foreach my $item (@{$self->Items}) {
		my ($key, $value) = %{$item};
		$command .= ' ' . $key . " '" . $value . "'";
 	}

	$command .= ' 2> ' . $self->TempFile;

	$self->_xlateExitCode(system($command));
}

1;
