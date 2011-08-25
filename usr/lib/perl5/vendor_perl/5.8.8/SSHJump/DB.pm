package SSHJump::DB;

use Moose;
use SSHJump::Moose::Types;

# List Properties
has 'Errors'   => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has 'Warnings' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

# Database Handle
has 'DBH'      => ( is => 'rw', isa => 'DBI', required => 1 );

# Public Methods
sub lastError {
	my ($self) = @_;
	my ($last_error);

	return undef unless(@{$self->Errors});

	$last_error = $self->Errors->[$#{$self->Errors}];
	$last_error =~ s/'//g;

	return $last_error;
}

# Private Methods
sub _warning {
	my ($self, $msg) = @_;
	push @{$self->{Warnings}}, $msg;
}

sub _error {
	my ($self, $msg) = @_;
	push @{$self->{Errors}}, $msg;
}

no Moose;

1;
