package SSHJump::DB::Join::UserSession;

use Moose;

extends 'SSHJump::DB';

# String Properties
has 'Reason'     => ( is => 'rw', isa => 'Str', default => '' );
has 'Status'     => ( is => 'rw', isa => 'Str', default => '' );
has 'TimeClosed' => ( is => 'rw', isa => 'Str', default => '' );
has 'TimeOpened' => ( is => 'rw', isa => 'Str', default => '' );
has 'Type'       => ( is => 'rw', isa => 'Str', default => '' );
has 'UserName'   => ( is => 'rw', isa => 'Str', default => '' );

# Integer Properties
has 'SessionID'  => ( is => 'rw', isa => 'Int', default => 0 );

# Public Methods

no Moose;

1;
