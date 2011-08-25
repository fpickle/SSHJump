package SSHJump::App::Control::Main;

use Moose;
use SSHJump::App::Control::Info;

extends 'SSHJump::App::Control', 'SSHJump::Dialog::Menu';

use constant DEFAULT_HEIGHT => 18;
use constant DEFAULT_WIDTH  => 60;
use constant DEFAULT_ITEMS  => 7;

# String Properties
has 'Access' => ( is      => 'rw',
                  isa     => 'Str',
                  default => '',
                  trigger => \&_load );

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->Title($self->Config->{'GUI_NAME'} . ' Administration');
	$self->Type('inputbox');

	$self->appendText($self->Config->{'GUI_NAME'} . ' v'                 );
	$self->appendText($self->Config->{'VERSION'} . ' - Welcome \Zb\Z4'   );
	$self->appendText($self->CurrentUser . '\Zn' . "!\n" . 'Powered by ' );
	$self->appendText('CentOS - Updated: ' . $self->Config->{'UPDATED'}  );
	$self->appendText("\n\n" . 'Comments? Bug reports? '                 );
	$self->appendText($self->Config->{'BUG_REPORT_HOWTO'}                );
	
	$self->Height(DEFAULT_HEIGHT) unless($self->Height);
	$self->Width(DEFAULT_WIDTH)   unless($self->Width);
	$self->ItemsShown(DEFAULT_ITEMS);
	$self->CancelLabel('Exit');
	$self->OKButton(1);
}

sub _load {
	my ($self) = @_;
	my $gui_name = $self->Config->{'GUI_NAME'};

	if($self->Access eq 'LOCKED') {
		my $info_box = new SSHJump::App::Control::Info( { Config => $self->Config } );

		$info_box->appendText('\Zb\Z1ACCESS DENIED\Zn '               );
		$info_box->appendText($self->CurrentUser . ' has been locked!');

		$info_box->show();
		&{$self->ExitHandler};
	} elsif ($self->Access eq 'USER') {
		my $info_box = new SSHJump::App::Control::Info( { Config => $self->Config } );

		$info_box->appendText('\Zb\Z1ACCESS DENIED\Zn '                         );
		$info_box->appendText('You do not have permission to use this interface');

		$info_box->show();
		&{$self->ExitHandler};
	} elsif ($self->Access eq 'ADMIN') {
		my $info_box = new SSHJump::App::Control::Info( { Config => $self->Config } );

		$info_box->appendText('\Zb\Z1ACCESS DENIED\Zn '                         );
		$info_box->appendText('You do not have permission to use this interface');

		$info_box->show();
		&{$self->ExitHandler};
		# $self->addItem({'SHELL' => 'Open an ssh shell to a remote host'});
	} elsif ($self->Access eq 'SUPERADMIN') {
		# $self->addItem({'SHELL' => 'Open an ssh shell to a remote host'});
		#$self->addItem({'FILTER' => 'IP connection filtering'            });
		$self->addItem({'HOSTS'  => 'Host management'                     });
		$self->addItem({'GROUPS' => 'Group management'                    });
		$self->addItem({'KEYS'   => 'Create/Register SSH keys'            });
		$self->addItem({'USERS'  => 'User management'                     });
		$self->addItem({'LOGS'   => 'Search/Playback Script logs' });
	}

	$self->addItem({'PROFILE' => 'Update your ' . $gui_name . ' profile'});
	$self->addItem({'EXIT' => 'Exit the ' . $gui_name                   });
}

no Moose;

1;
