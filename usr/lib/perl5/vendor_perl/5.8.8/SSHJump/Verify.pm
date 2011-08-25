package SSHJump::Verify;

use base Exporter;

@EXPORT = qw(
	ALPHNUM_REGEX
	ALPHNUM_SPACE_REGEX
	EMAIL_REGEX
	PHONE_REGEX
	PASSWD_REGEX
	HOST_REGEX
	PATH_REGEX
	STRING_REGEX
	SPACE_REGEX
);

use constant ALPHNUM_REGEX       => qr/^[A-Za-z0-9]+$/;
use constant ALPHNUM_SPACE_REGEX => qr/^[A-Za-z0-9 ]+$/;
use constant STRING_REGEX        => qr/^[^`<>|;\\"']+$/;
use constant SPACE_REGEX         => qr/\s/;

use constant EMAIL_REGEX   => qr/^[A-Za-z0-9_.]+@\w+\.[A-Za-z]{2,4}$/;
use constant PHONE_REGEX   => qr/^(\d(\s*|-))?\(?(\d{3})?\)?(\s*|-)?\d{3}(\s+|-)?\d{4}$/;
use constant PASSWD_REGEX  => qr/^.{8}/;
use constant HOST_REGEX    => qr/^((\.)?[A-Za-z0-9_-]+)+(\.[A-Za-z]{2,4})?$/;
use constant PATH_REGEX    => qr/^[:\/\.A-Za-z0-9_-]+$/;

1;
