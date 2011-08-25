package SSHJump::Constants;

use base Exporter;

@EXPORT = qw(
	DEFAULT_SHELL
	LOCK_SHELL
	SSHJUMP_GROUP
);

use constant DEFAULT_SHELL   => '/bin/bash';
use constant LOCK_SHELL      => '/sbin/nologin';
use constant SSHJUMP_GROUP   => 'sshjump';

1;
