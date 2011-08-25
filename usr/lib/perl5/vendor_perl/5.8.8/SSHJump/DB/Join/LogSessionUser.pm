package SSHJump::DB::Join::LogSessionUser;

use Moose;

extends 'SSHJump::DB';

# String Properties
has 'Email'         => ( is => 'rw', isa => 'Str', default => '' );
has 'LastEntryTime' => ( is => 'rw', isa => 'Str', default => '' );
has 'Phone'         => ( is => 'rw', isa => 'Str', default => '' );
has 'RealName'      => ( is => 'rw', isa => 'Str', default => '' );
has 'UserName'      => ( is => 'rw', isa => 'Str', default => '' );

# Integer Properties
has 'Sessions'      => ( is => 'rw', isa => 'Int', default => 0 );
has 'UserID'        => ( is => 'rw', isa => 'Int', default => 0 );

# Public Methods

no Moose;

1;
