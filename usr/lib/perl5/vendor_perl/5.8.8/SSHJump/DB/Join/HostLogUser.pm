package SSHJump::DB::Join::HostLogUser;

use Moose;

extends 'SSHJump::DB';

# String Properties
has 'HostName'  => ( is => 'rw', isa => 'Str', default => '' );
has 'EntryType' => ( is => 'rw', isa => 'Str', default => '' );
has 'EntryTime' => ( is => 'rw', isa => 'Str', default => '' );
has 'Entry'     => ( is => 'rw', isa => 'Str', default => '' );
has 'UserName'  => ( is => 'rw', isa => 'Str', default => '' );

# Integer Properties
has 'LogID'     => ( is => 'rw', isa => 'Int', default => 0 );

# Public Methods

no Moose;

1;
