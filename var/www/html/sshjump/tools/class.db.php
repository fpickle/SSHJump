<?php
  /**
   * General interface class for MySQL database queries
   *
   * This file contains the {@link db} class, as well as associated
   * constants.  Inclusion of this file will create a global handle
   * to an instance of the {@link db} class.
   *
   * @package  DB
   * @author  Michael A. Logdon-Porter <the.germanboy@gmail.com>
   * @version  1.5
   * @todo  Finish database class function commenting
   */
  /**
   * Site-wide constants
   *
   * Site-wide constant declarations, including database connection
   * information
   */
  require_once('config.php');

  /**
   * Define return types
   *
   * Definition of database row return types
   * - OBJECT is an object, where columns are referenced
   *   via row->colname
   * - ARRAY_A is an associative array, where columns are
   *   referenced via row['colname']
   * - ARRAY_N is a numerically-keyed array, where columns
   *   are referenced via row[colnumber]
   */
  define('OBJECT', 'OBJECT', true);
  define('ARRAY_A', 'ARRAY_A', false);
  define('ARRAY_N', 'ARRAY_N', false);

  /**
   * Whether or not to save previous queries
   */
  if (!defined('SAVEQUERIES'))
    define('SAVEQUERIES', true);

  /**
  * Interface class for MySQL database queries
  *
  * This class provides for easy functions to initiate a connection
  * to and query a MySQL database.  The default return-type of row select
  * queries is an object, with object->column groups.
  *
  * @package  DB
  */
  class db {
    /**
     * @var  bool  Whether database errors should be displayed in the page
     */
    var $show_errors = true;
    /**
     * @var  int  The number of queries executed on this connection (generally per page)
     */
    var $num_queries = 0;  
    /**
     * @var  string  The text of the last query
     */
    var $last_query;
    /**
     * @var  object  The connection handle to the MySQL server
     */
    var $dbh = null;
    /**
     * @var array  Array in which to store previous queries
     */
    var $savedqueries = array();
    /**
     * @var bool  Whether we are currently in a transaction
     */
    var $in_tx = 0;

    /**
     * Class constructor
     *
     * Creates a new connection to the MySQL database
     *
     * @param  string  $dbuser    The username to connect to the DBMS as
     * @param  string  $dbpassword  The password to use to login to the DBMS
     * @param  string  $dbname    The name of the database to connect to
     * @param  string  $dbhost    The hostname of the DBMS
     */
    function db($dbuser, $dbpassword, $dbname, $dbhost) {
      $this->dbh = @mysql_connect($dbhost,$dbuser,$dbpassword);
      if (!$this->dbh) {
        die("<div>
        <p><strong>Error establishing a database connection!</strong> This probably means that the connection information in your configuration file is incorrect. Double check it and try again.</p>
        <ul>
        <li>Are you sure you have the correct user/password?</li>
        <li>Are you sure that you have typed the correct hostname?</li>
        <li>Are you sure that the database server is running?</li>
        </ul>
        </div>");
      }

      $this->select($dbname);
    }

    /**
     * Select the database to use
     *
     * Uses mysql_select_db to select the database to perform queries on
     *
     * @param  string  $db  The name of the database to select
     */
    function select($db) {
      if (!@mysql_select_db($db,$this->dbh)) {
        die("
        <p>We're having a little trouble selecting the proper database for the iHigh points system.</p>
        <ul>
        <li>Are you sure it exists?</li>
        <li>Your database name is currently specified as <code>" . DB_NAME ."</code>. Is this correct?</li>
        </ul>");
      }
    }

    /**
     * Escape string for use in queries
     *
     * Escape the string for use in MySQL queries using the mysql_escape_string()
     * function
     * @param  string  $str  The string to escape
     * @return  string    Escaped string
     */
    function escape($str) {
      return mysql_escape_string(stripslashes($str));        
    }

    /**
     * Print last database error
     *
     * Prints the last stored database error in HTML format for display to
     * the user.  It only displays if db::show_errors is true.
     * @param  string  $str  The database error string
     * @see    db::last_query
     * @see    db::show_errors
     */
    function print_error($str = '') {
      global $EZSQL_ERROR;

      if (!$str) $str = mysql_error();
      $EZSQL_ERROR[] = array ('query' => $this->last_query, 'error_str' => $str);

      // Is error output turned on or not..
      if ( $this->show_errors ) {
        // If there is an error then take note of it
        print "<div id='error'>
        <p><strong>Database error:</strong> [$str]<br />
        <code>$this->last_query</code></p>
        </div>";
      } else {
        return false;  
      }
    }

    /**
     * Print saved queries
     *
     * Prints the queries saved during this session (typically throughout one page view)
     * @see    db::savedqueries
     */
    function print_queries() {
      if ($this->savedqueries) {
        foreach ($this->savedqueries as $query) {
          print $query . "\n";
        }
      }
    }

    /**
     * Turn error handling on
     */
    function show_errors() {
      $this->show_errors = true;
    }

    /**
     * Turn error handling off
     */
    function hide_errors() {
      $this->show_errors = false;
    }

    /**
     * Flush last query results
     */
    function flush() {
      $this->last_result = null;
      $this->col_info = null;
      $this->last_query = null;
    }

    /**
     * Execute a query
     *
     * Execute the query on the current MySQL database connection.
     * No rows are returned -- any rows from the query are stored
     * for use by the various other processing functions.  The number
     * of affected / selected rows is returned.
     * @param  string  $query  The query to execute
     * @return  integer  The number of affected / selected rows
     */
    function query($query) {
      // initialise return
      $return_val = 0;
      $this->flush();

      // Log how the function was called
      $this->func_call = "\$db->query(\"$query\")";

      // Keep track of the last query for debug..
      $this->last_query = $query;

      // Perform the query via std mysql_query function..
      $this->result = @mysql_query($query,$this->dbh);
      ++$this->num_queries;
      if (SAVEQUERIES) {
        $this->savedqueries[] = $query;
      }

      // If there is an error then take note of it..
      if ( mysql_error() ) {
        $this->print_error();
        return false;
      }

      if ( preg_match("/^\\s*(insert|delete|update|replace) /i",$query) ) {
        $this->rows_affected = mysql_affected_rows();
        // Take note of the insert_id
        if ( preg_match("/^\\s*(insert|replace) /i",$query) ) {
          $this->insert_id = mysql_insert_id($this->dbh);  
        }
        // Return number of rows affected
        $return_val = $this->rows_affected;
      } else {
        $i = 0;
        while ($i < @mysql_num_fields($this->result)) {
          $this->col_info[$i] = @mysql_fetch_field($this->result);
          $i++;
        }
        $num_rows = 0;
        while ( $row = @mysql_fetch_object($this->result) ) {
          $this->last_result[$num_rows] = $row;
          $num_rows++;
        }

        @mysql_free_result($this->result);

        // Log number of rows the query returned
        $this->num_rows = $num_rows;
      
        // Return number of rows selected
        $return_val = $this->num_rows;
      }

      return $return_val;
    }

    function tx_query($query) {
      $this->flush();

      // Log how the function was called
      $this->func_call = "\$db->" . strtolower($query) . "_tx()";

      // Keep track of the last query for debug..
      $this->last_query = $query;

      // Perform the query via std mysql_query function..
      $this->result = @mysql_query($query,$this->dbh);
      ++$this->num_queries;
      if (SAVEQUERIES) {
        $this->savedqueries[] = $query;
      }

      // If there is an error then take note of it..
      if ( mysql_error() ) {
        $this->print_error();
        return false;
      }
      return true;
    }

    function begin_tx() {
      if ($this->in_tx) {
        $this->in_tx++;
        return true;
      }

      $this->flush();

      // Log how the function was called
      $this->func_call = "\$db->begin_tx()";

      $query = "SET AUTOCOMMIT = 0";

      // Keep track of the last query for debug..
      $this->last_query = $query;

      // Perform the query via std mysql_query function..
      $this->result = @mysql_query($query,$this->dbh);
      ++$this->num_queries;
      if (SAVEQUERIES) {
        $this->savedqueries[] = $query;
      }

      // If there is an error then take note of it..
      if ( mysql_error() ) {
        $this->print_error();
        return false;
      }

      $this->in_tx++;

      return $this->tx_query("BEGIN");
    }

    function commit_tx() {
      if ($this->in_tx > 1) {
        $this->in_tx--;
        return true;
      } else if ($this->in_tx == 1) {
        $this->in_tx = 0;
        return $this->tx_query("COMMIT") && $this->query("SET AUTOCOMMIT = 1");
      }
      return false;
    }

    function rollback_tx() {
      if (!$this->in_tx) {
        return true;
      }
      $this->in_tx = 0;
      return $this->tx_query("ROLLBACK") && $this->query("SET AUTOCOMMIT = 1");
    }

    // ==================================================================
    //  Get one variable from the DB - see docs for more detail

    function get_var($query=null, $x = 0, $y = 0) {
      $this->func_call = "\$db->get_var(\"$query\",$x,$y)";
      if ( $query )
        $this->query($query);

      // Extract var out of cached results based x,y vals
      if ( $this->last_result[$y] ) {
        $values = array_values(get_object_vars($this->last_result[$y]));
      }

      // If there is a value return it else return null
      return (isset($values[$x]) && $values[$x]!=='') ? $values[$x] : null;
    }

    // ==================================================================
    //  Get one row from the DB - see docs for more detail

    function get_row($query = null, $output = OBJECT, $y = 0) {
      $this->func_call = "\$db->get_row(\"$query\",$output,$y)";
      if ( $query )
        $this->query($query);

      if ( $output == OBJECT ) {
        return $this->last_result[$y] ? $this->last_result[$y] : null;
      } elseif ( $output == ARRAY_A ) {
        return $this->last_result[$y] ? get_object_vars($this->last_result[$y]) : null;
      } elseif ( $output == ARRAY_N ) {
        return $this->last_result[$y] ? array_values(get_object_vars($this->last_result[$y])) : null;
      } else {
        $this->print_error(" \$db->get_row(string query, output type, int offset) -- Output type must be one of: OBJECT, ARRAY_A, ARRAY_N");
      }
    }

    // ==================================================================
    //  Function to get 1 column from the cached result set based in X index

    function get_col($query = null , $x = 0) {
      $new_array = array();
      if ( $query )
        $this->query($query);

      // Extract the column values
      for ( $i=0; $i < count($this->last_result); $i++ ) {
        $new_array[$i] = $this->get_var(null, $x, $i);
      }
      return $new_array;
    }

    // ==================================================================
    // Return the the query as a result set - see docs for more details

    function get_results($query = null, $output = OBJECT) {
      $this->func_call = "\$db->get_results(\"$query\", $output)";

      if ( $query )
        $this->query($query);

      // Send back array of objects. Each row is an object
      if ( $output == OBJECT ) {
        return $this->last_result;
      } elseif ( $output == ARRAY_A || $output == ARRAY_N ) {
        if ( $this->last_result ) {
          $i = 0;
          foreach( $this->last_result as $row ) {
            $new_array[$i] = (array) $row;
            if ( $output == ARRAY_N ) {
              $new_array[$i] = array_values($new_array[$i]);
            }
            $i++;
          }
          return $new_array;
        } else {
          return null;
        }
      }
    }


    // ==================================================================
    // Function to get column meta data info pertaining to the last query
    // see docs for more info and usage

    function get_col_info($info_type = 'name', $col_offset = -1) {
      if ( $this->col_info ) {
        if ( $col_offset == -1 ) {
          $i = 0;
          foreach($this->col_info as $col ) {
            $new_array[$i] = $col->{$info_type};
            $i++;
          }
          return $new_array;
        } else {
          return $this->col_info[$col_offset]->{$info_type};
        }
      }
    }

    function get_enum_values($table, $column) {
      $sql = "SHOW COLUMNS FROM " . $table . " LIKE '" . $column . "'";
      $query = @mysql_query($sql);

      $row = @mysql_fetch_assoc($query);
      $enums = $row["Type"];

      $enums = substr($enums, 6, strlen($enums)-8);
      $enums = str_replace("','", ",", $enums);

      return explode(",", $enums);
    }

    function is_error() {
      return (mysql_errno() != 0);
    }
  }

  /**
   * Create a new database connection using defined 
   * parameters
   *
   * @see DB_USER
   * @see DB_PASS
   * @see DB_NAME
   * @see DB_HOST
   * @see sitevars.inc.php
   * @global  object  $db
   */
  $db = new db(DB_USER, DB_PWD, DB_NAME, DB_HOST);

?>
