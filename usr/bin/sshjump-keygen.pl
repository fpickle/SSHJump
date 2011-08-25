#!/usr/bin/perl

use strict;
use Getopt::Long;
use Config::General;

use SSHJump::System::Call::SshKeygen;

my %config   = Config::General::ParseConfig($ENV{'SSHJUMP_CONF'});
my ($help, $type, $size, $file, $dir, $passphrase);
my $result = GetOptions( 'help|h'          => \$help,
                         'type|t=s'        => \$type,
                         'size|s=s'        => \$size,
                         'file|f=s'        => \$file,
                         'dir|d=s'         => \$dir,
                         'passphrase|p=s'  => \$passphrase );

# Set defaults...
$type       = 'rsa'                  unless($type);
$size       = 4096                   unless($size);
$dir        = $config{'SSH_KEY_DIR'} unless($dir);
$passphrase = ''                     unless($passphrase);

# Check required input...
&usage() if(!$result || $help);
&usage('--file required') unless($file);

&_generateKey($type, $size, $file, $dir, $passphrase);
exit 0;

################################################################################

sub usage {
  my ($msg) = @_;

  print "\n";
  print $msg . "\n\n" if($msg);
  print 'Usage:' . "\n";

  print '  ' . $0 . ' [--type|-t <type>] [--size|-s <size>] ';
  print '[--dir|-d <directory>] [--passphrase|-p <passphrase>] ';
  print '--file|-f <file>' . "\n";

  print "\n";

  print 'Options:' . "\n";
  print "  --help|-h      \t" . 'Print this help message' . "\n";
  print "  --type|-t      \t" . 'SSH key type (rsa or dsa)' . "\n";
  print "  --size|-s      \t" . 'SSH key size' . "\n";
  print "  --file|-f      \t" . 'Key file name' . "\n";
  print "  --dir|-d       \t" . 'Key directory' . "\n";
  print "  --passphrase|-p\t" . 'Key passphrase' . "\n";
  print "\n";

  exit 0;
}

sub _generateKey {
  my ($type, $size, $file, $dir, $passphrase) = @_;
  my $o_sshkeygen = new SSHJump::System::Call::SshKeygen( {
    Type       => $type,
    Size       => $size,
    KeyName    => $file,
    KeyDir     => $dir,
    Passphrase => $passphrase
  } );

  print $o_sshkeygen->Command . "\n";

  if($o_sshkeygen->ExitCode) {
    print STDERR 'ssh-keygen exited with status ' . $o_sshkeygen->ExitCode . "\n";
    exit 1;
  }
}
