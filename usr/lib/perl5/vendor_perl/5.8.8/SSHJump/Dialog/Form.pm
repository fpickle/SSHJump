package SSHJump::Dialog::Form;

use Moose;

extends 'SSHJump::Dialog';

# Integer Properties
has 'FormHeight' => ( is => 'rw', isa => 'Int', default => 3 );

# Array Properties...should probably be another object
has 'Fields'     => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

sub addField {
	my ($self, $field_data) = @_;
	push @{$self->{Fields}}, $field_data;
}

sub cleanFields {
	my ($self) = @_;
	$self->{Fields} = [];
}

sub render {
	my ($self) = @_;
	my $rv = 0;
	my $command = $self->Command;

	$command .= ' --clear'   if($self->Clear);
	$command .= ' --colors'  if($self->Colors);
	$command .= ' --cr-wrap' if($self->CrWrap);
	$command .= ' --ignore'  if($self->Ignore);

	$command .= ' --no-cancel' unless($self->CancelButton);

	$command .= " --title '" . $self->Title . "'";
	$command .= " --sleep '" . $self->Sleep if($self->Sleep);

	# standard dialogs accept text, height, width args...
	$command .= " --form '" . $self->Text . "'";
	$command .= ' ' . $self->Height;
	$command .= ' ' . $self->Width;
	$command .= ' ' . $self->FormHeight;

	foreach my $field (@{$self->Fields}) {
		foreach my $element (@{$field}) {
			if($element !~ m/^\d+$/) {
				$command .= " '" . $element . "'";
			} else {
				$command .= ' ' . $element;
			}
		}
 	}

	$command .= ' 2> ' . $self->TempFile;

	$self->_xlateExitCode(system($command));
}

1;
