package SSHJump::App::Control::ScriptChoice;

use Moose;
use SSHJump::DB::Collection::Join::HostLogSessionUser;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 18;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 10;

# String Properties
has 'User'      => ( is => 'rw', isa => 'Str', default => '' );
has 'LogFile'   => ( is => 'rw', isa => 'Str', default => '' );
has 'StartDate' => ( is => 'rw', isa => 'Str', default => '' );
has 'EndDate'   => ( is => 'rw', isa => 'Str', default => '' );

has 'Host' => (
	is      => 'rw',
	isa     => 'Str',
	default => '',
	trigger => \&_verifyHost
);

# Database Handle
has 'DBH' => ( is => 'rw', isa => 'Object', required => 1 );

# Private Methods
sub BUILD {
	my ($self) = @_;
	my ($obj_config, $c_script);

	$obj_config = {
		DBH               => $self->DBH,
		Status            => 'CLOSED',
		LogFileIsNotEmpty => 1,
		UserName          => $self->User,
		HostName          => $self->Host,
		LogFile           => $self->LogFile,
		TimeOpened        => $self->StartDate,
		TimeClosed        => $self->EndDate
	};

	$c_script  = new SSHJump::DB::Collection::Join::HostLogSessionUser($obj_config);

	$self->Title('Script Playback');
	$self->Text('Choose script log for playback.' . "\n");
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelButton(1);

	if($c_script->Collection) {
		foreach my $o_script (@{$c_script->Collection}) {
			my $description  = $o_script->TimeOpened . ' ' . $o_script->UserName;
			   $description .= ' ' . $o_script->HostName;
			$self->addItem({$o_script->SessionID => $description});
		}
	}

	$self->addItem({'BACK' => 'Return to previous menu'});
}

sub _verifyHost {
	my ($self) = @_;
	my $o_host = new SSHJump::DB::Host( {
		DBH => $self->DBH,
		HostName => $self->Host
	} );

	# Lookup by either hostname or alias...
	$self->{'Host'} = $o_host->HostName;
}

no Moose;

1;
