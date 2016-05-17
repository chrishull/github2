package co.spillikin.web.database;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

/**
 * Basic wrapper for JDBC / MariaDB.  Handles a few basic functions.
 * 
 * See MariaDB
 * https://mariadb.com/kb/en/mariadb/about-mariadb-connector-j/
 * 
 * @author chris
 *
 */
public class JDBCWrapper {
	
	// Full DB connect URL looks like this
	// "jdbc:mariadb://localhost:3306/?user=root&password=z00l00k"
	private static final String DB_URL = "jdbc:mariadb://localhost:3306/";
	
	// Log4j
	private static final Logger log = Logger.getLogger(JDBCWrapper.class);
	
	// Shared connection
	private Connection conn = null;
	
	// Current database name
	private String dbName = null;
	
	/**
	 * Create our wrapper object and connect to DB for the first time.
	 * If the given database doesn't exist, then retry with none.
	 * Check getConnection() for NULL to see if it was successful.
	 * 
	 * @param Database name
	 * @param password
	 */
	public JDBCWrapper (String databaseNam, String password) {
		if ( createConnection( databaseNam,  password) == null )  {
			log.info("Could not connect to database " + databaseNam + 
					" Trying default.");
			createConnection( "", password);
		}
	}
	
	/**
	 * Create our wrapper object and connect to DB for the first time.
	 * If database not created yet, this is the password only entry.
	 * See note above.
	 * @param password
	 */
	public JDBCWrapper (String password) {
		createConnection( "",  password);
	}
	
	/**
	 * Connection factory.   Will not reconnect unless connection is closed or NULL.
	 * 
	 * @String Database name or "" if default.
	 * @String password.
	 * @returns Connection or NULL.
	 */
	public Connection createConnection(String databaseNam, String password ) {
		if (conn != null) {
			log.error("You must close the current connection before creating a new one.");
			return conn;
		}
		if ( databaseNam == "") {
			dbName = null;
		} else {
			dbName = databaseNam;
		}
		
		Connection c = null;
		try { 
			String fullURL = DB_URL + databaseNam + "?user=root&password=" + password;
			log.info("Trying to connect to " + fullURL);
			c = DriverManager.getConnection(fullURL);  
			log.info("Connection successful.");
		} catch (SQLException e) { 
			// e.printStackTrace(); 
			log.error("Failed to create db connection" + e.getMessage() );
			c = null;
		} 
		conn = c;
		return conn;
	}
	
	/**
	 * Return the name of the database we last connected to.
	 * Null if default.
	 * @return
	 */
	public String getCurrentDatabaseName () {
		return dbName;
	}
	
	/**
	 * Get the current database connection object.  Null if closed or errored.
	 * @return DB connection
	 */
	public Connection getCurrentConnection () {
		return conn;
	}
	
	/**
	 * Close the current connection.
	 */
	public void closeConnection () {
		if ( conn == null ) {
			log.error("Connection is null.  Can not close.");
			return;
		}
		try {
			conn.close();
		} catch (SQLException e) {
			log.error("Error closing connection." + e.getMessage());
		}
		conn = null;
		dbName = null;
	}
	
	
	/**
	 * A convenient ExecuteUpdate wrapper.  Simply returns true / false if
	 * it worked.
	 * 
	 * @param sql
	 * @return True of success.
	 */
	public boolean executeUpdate ( String sql ) {
		
		if (conn == null ) {
			log.error("Must create a connection forst.  Aborting.");
			return false;
		}
		Statement statement = null;
		try {
			statement = conn.createStatement();
			statement.executeUpdate(sql);
			log.info("executeUpdate successful: " + sql);
			return true;
		} catch (SQLException se){
			//Handle errors for JDBC
			log.error("executeUpdate error: " + se.getMessage());
		} catch (Exception e) {
			//Handle errors for Class.forName
			log.error("executeUpdate error: " + e.getMessage());
		} finally {
	      //finally block used to close resources
			try {
				if(statement != null)
					statement.close();
			} catch (SQLException se2) {
				// nothing to do.
			}
		}
		return false;
	}
	
	/**
	 * Commonly used, Create a database
	 * @String DB Name
	 */
	public boolean createDatabse ( String dbName ) {
		return executeUpdate ( "CREATE DATABASE " + dbName);
	}
	
	/**
	 * Commonly used, Delete a database
	 * @String DB Name
	 */
	public boolean deleteDatabse ( String dbName ) {
		return executeUpdate ( "DROP DATABASE " + dbName);
	}
	
	/**
	 * Check to see if the database exists already.
	 * @param name
	 * @return
	 */
	public boolean databaseExists ( String name ) {
		// Always returns a list
		String[] dbList = getDatabaseList();
		for ( String s : dbList) {
			if ( s.equalsIgnoreCase (name) ) {
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Get database list
	 * @throws  
	 */
	public String[] getDatabaseList ()  {
		if (conn == null ) {
			log.error("Must create a connection forst.  Aborting.");
			return new String[0];
		}
		List<String> l = new ArrayList<String>();
		DatabaseMetaData meta;
		try {
			meta = conn.getMetaData();
		} catch (SQLException e) {
			log.error(e.getMessage());
			return l.toArray(new String[0]);
		}
		ResultSet res = null;
		try {
			res = meta.getCatalogs();
			while (res.next()) {
			   String db = res.getString("TABLE_CAT");
			   l.add(db);
			}
			res.close();
			log.info("Successfully got database names.");
			return l.toArray(new String[0]);
		} catch (SQLException e) {
			log.error(e.getMessage());
			return l.toArray(new String[0]);
		} finally {
			try {
				res.close();
			} catch (SQLException e) {
				return l.toArray(new String[0]);
			}
		}
	}
	
	public ResultSet executeQuery(String sql) {
		if (conn == null ) {
			log.error("Must create a connection first. Aborting.");
			return null;
		}
		Statement statement = null;
		try {
			statement = conn.createStatement();
			ResultSet rs = statement.executeQuery(sql);
			log.info("executeQuery successful: " + sql);
			return rs;
		} catch (SQLException se){
			//Handle errors for JDBC
			log.error("executeQuery error: " + se.getMessage());
		} catch (Exception e) {
			//Handle errors for Class.forName
			log.error("executeQuery error: " + e.getMessage());
		} finally {
	      //finally block used to close resources
			try {
				if(statement != null)
					statement.close();
			} catch (SQLException se2) {
				// nothing to do.
			}
		}
		return null;
	}

	  private void doInsertTest()
	  {
	    System.out.print("\n[Performing INSERT] ... ");
	    try
	    {
	      Statement st = conn.createStatement();
	      st.executeUpdate("INSERT INTO COFFEES " +
	                       "VALUES ('BREAKFAST BLEND', 200, 7.99, 0, 0)");
	    }
	    catch (SQLException ex)
	    {
	      System.err.println(ex.getMessage());
	    }
	  }

	  private void doUpdateTest()
	  {
	    System.out.print("\n[Performing UPDATE] ... ");
	    try
	    {
	      Statement st = conn.createStatement();
	      st.executeUpdate("UPDATE COFFEES SET PRICE=4.99 WHERE COF_NAME='BREAKFAST BLEND'");
	    }
	    catch (SQLException ex)
	    {
	      System.err.println(ex.getMessage());
	    }
	  }

	  private void doDeleteTest()
	  {
	    System.out.print("\n[Performing DELETE] ... ");
	    try
	    {
	      Statement st = conn.createStatement();
	      st.executeUpdate("DELETE FROM COFFEES WHERE COF_NAME='BREAKFAST BLEND'");
	    }
	    catch (SQLException ex)
	    {
	      System.err.println(ex.getMessage());
	    }
	  }
	  

}
