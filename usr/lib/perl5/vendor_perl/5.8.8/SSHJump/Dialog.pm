package SSHJump::Dialog;

use Moose;
use File::Basename;

use SSHJump::Utils;

# Boolean Properties
has 'CancelButton' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'Clear'        => ( is => 'rw', isa => 'Bool', default => 0 );
has 'Colors'       => ( is => 'rw', isa => 'Bool', default => 1 );
has 'CrWrap'       => ( is => 'rw', isa => 'Bool', default => 1 );
has 'OKButton'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'Ignore'       => ( is => 'rw', isa => 'Bool', default => 0 );

# String Properties
has 'Caller'       => ( is => 'ro', isa => 'Str', default => (caller())[1] );
has 'ExitMsg'      => ( is => 'ro', isa => 'Str', default => ''       );
has 'TempDir'      => ( is => 'rw', isa => 'Str', default => ''       );
has 'TempFile'     => ( is => 'rw', isa => 'Str', lazy_build => 1     );
has 'Text'         => ( is => 'rw', isa => 'Str', default => ''       );
has 'Title'        => ( is => 'rw', isa => 'Str', default => ''       );
has 'Type'         => ( is => 'rw', isa => 'Str', default => ''       );
has 'Command'      => ( is => 'rw', isa => 'Str', default => 'dialog' );
has 'CancelLabel'  => ( is => 'rw', isa => 'Str', default => ''       );

# Integer Properties
has 'ExitCode'     => ( is => 'ro', isa => 'Int', default => 0 );
has 'Height'       => ( is => 'rw', isa => 'Int', default => 0 );
has 'Sleep'        => ( is => 'rw', isa => 'Int', default => 0 );
has 'Width'        => ( is => 'rw', isa => 'Int', default => 0 );

# List Properties
has 'EXIT_CODES' => ( is => 'ro', isa => 'HashRef', default => sub {
	{
		0   => 'YES/OK',
		1   => 'NO/CANCEL',
		2   => 'HELP',
		3   => 'EXTRA',
		-1  => 'ERR',
		255 => 'ESC'
	}
} );

# Builder Methods
sub _build_TempFile {
	my ($self) = @_;
	my $file_path = '';

	if($self->TempDir) {
		SSHJump::Utils::prepareDirectory($self->TempDir, 700);
		$file_path = $self->TempDir . '/';
	}

	$file_path .= basename($self->Caller) . '.' . $$;
	return $file_path;
}

# Public Methods
sub appendText {
	my ($self, $string) = @_;
	$self->{Text} .= $string;
}

sub getData {
	my ($self) = @_;
	my @data = ();

	unless(open(TMP, '<' . $self->TempFile)) {
		die 'Cannot open ' . $self->TempFile . ':  ' . $!;
	}

	while(my $line = <TMP>) {
		chomp($line);
		push @data, $line;
	}

	close(TMP);

	return @data if(wantarray);
	return $data[0];
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
	$command .= ' --no-ok'     unless($self->OKButton);

	$command .= " --title '" . $self->Title . "'";
	$command .= ' --sleep ' . $self->Sleep if($self->Sleep);
	
	# standard dialogs accept text, height, width args...
	$command .= ' --' . $self->Type . " '" . $self->Text . "'";
	$command .= ' ' . $self->Height;
	$command .= ' ' . $self->Width;

	$command .= ' 2> ' . $self->TempFile;

	$self->_xlateExitCode(system($command));
}

# Private Methods
sub _xlateExitCode {
	my ($self, $code) = @_;

	$self->{ExitCode} = $code >> 8;
	$self->{ExitMsg}  = $self->EXIT_CODES->{$self->ExitCode};
}

# Destructor
sub DEMOLISH {
	my ($self) = @_;
	unlink $self->TempFile;
}

# I do not want to export anything...
no Moose;

1;
