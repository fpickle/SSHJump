package SSHJump::App::Verify::String;

use Moose;

use SSHJump::Verify;
extends 'SSHJump::App::Verify', 'SSHJump::Verify::String';

# Private Methods
sub BUILD {
	my ($self) = @_;

	$self->{'Verified'} = $self->verify();

	unless($self->Verified) {
		$self->{'Error'}  = 'The characters \Zb\Z4' . $self->_regexToStr() . '\Zn ';
		$self->{'Error'} .= 'are not allowed in ' . $self->Description . '.' . "\n";
	}
}

sub _regexToStr {
	my ($self) = @_;
	my $regex = STRING_REGEX;

	if($regex =~ m/\[\^(.*)\]/) {
		my $rv = $1;

		$rv =~ s/'/ and single quote/g;
		return $rv;
	}

	return undef;
}

no Moose;

1;
