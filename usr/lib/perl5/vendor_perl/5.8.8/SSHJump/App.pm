package SSHJump::App;

use Moose;

use SSHJump::Constants;
use SSHJump::Moose::Types;

use SSHJump::App::Verify::AlphaNumeric;
use SSHJump::App::Verify::Email;
use SSHJump::App::Verify::Host;
use SSHJump::App::Verify::Passwd;
use SSHJump::App::Verify::Path;
use SSHJump::App::Verify::Phone;
use SSHJump::App::Verify::Space;
use SSHJump::App::Verify::String;

### Generic Method Declarations ################################################
sub inputCheck;

### Generic Method Definitions #################################################
sub inputCheck {
	my ($self, $string, $description, $type) = @_;
	my ($o_verify);

	$type = ($type) ? $type : '';
	$description = ($description) ? $description : '';

	# Allow empty strings...
	return 1 unless($string);

	# Skip badCharCheck for passwords...
	if($type eq 'password') {
		$o_verify = new SSHJump::App::Verify::Passwd( { Passwd => $string, } );
	} else {
		$o_verify = new SSHJump::App::Verify::String( {
			String => $string,
			Description => $description
		} );

		if($o_verify->Error) {
			$o_verify->renderError();
			return 0;
		}

		if($type eq 'path') {
			$o_verify = new SSHJump::App::Verify::Path({ Path => $string });
		} elsif($type eq 'email') {
			$o_verify = new SSHJump::App::Verify::Email({ Email => $string });
		} elsif($type eq 'phone') {
			$o_verify = new SSHJump::App::Verify::Phone({ Phone => $string });
		} elsif($type eq 'host') {
			$o_verify = new SSHJump::App::Verify::Host({ Host => $string });
		} elsif($type eq 'nospace') {
			$o_verify = new SSHJump::App::Verify::Space({ String => $string });
		} elsif($type eq 'alpha_numeric') {
			$o_verify = new SSHJump::App::Verify::AlphaNumeric({ String => $string });
		} elsif($type eq 'alpha_numeric_space') {
			$o_verify = new SSHJump::App::Verify::AlphaNumeric({
				String => $string,
				NoSpace => 0
			});
		}
	}

	if($o_verify->Error) {
		$o_verify->renderError();
		return 0;
	}

	return 1;
}

no Moose;

1;
