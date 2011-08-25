<html>
<body>
<h2>Update Mirth Server</h2>

<form name="input" action="execute.php" method="post">

<table>
<tr>
  <td width=300px>Choose server and click 'Update Mirth':</td>
  <td width=200px>
<?
  require('class.db.php');
  global $db;

  $results = getServers($db);
  echo generateSelect('server', $results);
?>
  </td>
  <td><input type="submit" value="Update Mirth" /></td>
</tr>
</table>

</form> 
</body>
</html>

<?
  # Functions
  function generateSelect($name = '', $options = array()) {
    $html = '<select name="'.$name.'">';
    foreach ($options as $option) {
      $html .= '<option value='.$option.'>'.$option.'</option>';
    }
    $html .= '</select>';
    return $html;
  }

  function getServers($db) {
    $sql  = 'select host.hostname';
    $sql .= ' from host, host_group, `group`';
    $sql .= ' where';
    $sql .= ' host_group.group_id=`group`.id';
    $sql .= ' and groupname=\'MirthAlpha\'';
    $sql .= ' and host.id=host_group.host_id';

    $results = $db->get_col($sql);
    return $results;
  }
?>
