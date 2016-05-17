package co.spillikin.web.database;

import java.sql.ResultSet;
import java.sql.SQLException;


public class TableDao implements java.io.Serializable {

	private static final long serialVersionUID = 4491501862099149291L;

	private static final String videoDbName = "VIDEO";
	private static final String videoDbPswd = "z00l00k";

	public String tableName = "";
	public String createTableSql = "";
	public String insertSql = "";
	public int id = 0;


	public void setId(int id) {
		this.id = id;
	}

	public String getTableName() {
		return tableName;
	}

	public int getId() {
		return id;
	}

	public boolean createTable() {
		// Choose database.
		JDBCWrapper jdbcWrapper = new JDBCWrapper(videoDbName, videoDbPswd);
		jdbcWrapper.executeQuery("USE " + videoDbName);
		
		// Create table.
		return jdbcWrapper.executeUpdate(createTableSql);
	}

	public boolean insertIntoTable() {
		// Choose database.
		JDBCWrapper jdbcWrapper = new JDBCWrapper(videoDbName, videoDbPswd);
		jdbcWrapper.executeQuery("USE " + videoDbName);
		
		// Create a row in the file table.
		boolean result = jdbcWrapper.executeUpdate(insertSql);
		
		// Store the id away.
		if (result) {
			id = getLastIdFromTable(jdbcWrapper);
		}
		
		return result;
	}

	public ResultSet getResultSet(String columnName, String columnValue) {
		// Choose database.
		JDBCWrapper jdbcWrapper = new JDBCWrapper(videoDbName, videoDbPswd);
		jdbcWrapper.executeQuery("USE " + videoDbName);
		
		// Do a select from the table on columnName with columnValue.
		String sql = "SELECT * FROM " + tableName + " WHERE " + columnName + "='" + columnValue + "'";
		return jdbcWrapper.executeQuery(sql);
	}
	
	private int getLastIdFromTable(JDBCWrapper jdbcWrapper) {
		String sql = "SELECT MAX(id) FROM " + tableName;
		ResultSet rs = jdbcWrapper.executeQuery(sql);
		try {
			rs.first();
			return rs.getInt("MAX(id)");
		} catch (SQLException e1) {
			System.out.println("SQLException: getLastIdFromTable():" + e1.getMessage());
			return 0;
		}
	}
	
}
