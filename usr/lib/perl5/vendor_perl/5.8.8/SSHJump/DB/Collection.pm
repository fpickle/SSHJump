package SSHJump::DB::Collection;

use Moose;
use JSON;

extends 'SSHJump::DB';

# List Properties
has 'Collection' => ( is => 'ro', isa => 'ArrayRef' );

# Public Methods
sub addMember {
	my ($self, $member_obj) = @_;
	push @{$self->{Collection}}, $member_obj;
}

sub removeMember {
	my ($self) = @_;
	print STDERR "removeMember method must be implemented in child object\n";
}

sub toJSON {
	my ($self) = @_;
	my $json = new JSON;
	my $records = [];

	return unless($self->Collection);

	foreach my $obj (@{$self->Collection}) {
		my $record = {};

		foreach my $key (sort keys %{$obj}) {
			next if($key eq 'DBH');
			$record->{$key} = $obj->$key;
		}

		push @{$records}, $record;
	}

	return $json->encode($records);
}

no Moose;

1;
