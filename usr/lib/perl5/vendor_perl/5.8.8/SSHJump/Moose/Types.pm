package SSHJump::Moose::Types;

use Moose;
use Moose::Util::TypeConstraints;

use SSHJump::Verify;

subtype 'Actions'
  => as 'Object'
  => where { ref($_) =~ m/^SSHJump::App::Actions$/ };

subtype 'CleanStr'
  => as 'Str'
  => where { STRING_REGEX || /^$/};

subtype 'DBI'
  => as 'Object'
  => where { ref ($_) =~ m/^DBI::db$/ };

subtype 'Log'
  => as 'Object'
  => where { ref($_) =~ m/^SSHJump::DB::Log$/ };

subtype 'PathStr'
  => as 'Str'
  => where { PATH_REGEX };

subtype 'Session'
  => as 'Object'
  => where { ref($_) =~ m/^SSHJump::DB::Session$/ };

no Moose;

1;
