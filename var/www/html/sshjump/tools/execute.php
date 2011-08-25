<html>
<body>
<?
  $remote_user = 'icatech2';
  $server      = escapeshellarg($_POST['server']);
  $web_user    = $_SERVER['PHP_AUTH_USER'];

  $execute     = '. /etc/profile.d/mirth.sh && ';
  $execute    .= 'sudo ica_rhn_channel_export --auto';

  $command     = "sshjump -u '$remote_user' -h $server";

  stream($command . " -m '$web_user:Automated Mirth Update' -e '$execute' 2>&1");
  stream($command . " -m '$web_user:Restarting Mirth' --restart 'mirth' 2>&1");

  function stream($command = '') {
    $stream = popen($command, 'r');

    while(!feof($stream)) {
      $output = fgets($stream);
      echo replace($output) . "<br>\n";
      ob_flush();
      flush();
    }

    pclose($stream);
  }

  function replace($string = '') {
    $regex = array(
       '/\x1B\[1;32m(.*?)(\x1B\[)/' => '<span style="color: green">$1</span>$2',
       '/\x1B\[1;33m(.*?)(\x1B\[)/' => '<span style="color: red">$1</span>$2',
       '/\x1B\[1;36m/'              => '',
       '/\x1B\[H/'                  => '',
       '/\x1B\[2J/'                 => '',
       '/\x1B\[0m/'                 => '',
       '/#/'                        => ''
    );

    foreach($regex as $key => $value) {
      $string = preg_replace($key, $value, $string);
    }

    return $string;
  }
?>
</body>
</html>
