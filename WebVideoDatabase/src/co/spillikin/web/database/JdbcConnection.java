package co.spillikin.web.database;




public class JdbcConnection { 
	public static void main(String a[]){ 

		System.out.println("Remember to start maria: mysql.server start");
		
		JdbcConnection jc = new JdbcConnection();
		System.out.println("Database: " + jc.getSomething () );
		
		//s.deleteDatabse("VIDEO");
		//s.createDatabse("VIDEO");
		// s.executeQuery("USE VIDEO");
		//s.executeUpdate("CREATE TABLE file (name varchar(64), date DATE, size int, path varchar(255))");
		//s.executeUpdate("INSERT INTO file (name,date,size,path) VALUES ('purplerain.mp4','2016-04-21',5000,'/blah/bloh/purplerain.mp4')");
		// s.executeQuery("SELECT * FROM file");
	}
	
	public String getSomething () {
		
		JDBCWrapper s = new JDBCWrapper("ddddd", "z00l00k");
		s.createDatabse("BAR1");
		s.deleteDatabse("BAR1");
		String[] dbList = s.getDatabaseList();
		StringBuffer sb = new StringBuffer();
		for ( String ss : dbList ){
			sb.append("Database: " + ss + "<br>\n");
		}
		return sb.toString();
		
	}
}

