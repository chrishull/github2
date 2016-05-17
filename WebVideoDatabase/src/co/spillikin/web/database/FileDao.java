package co.spillikin.web.database;

import org.apache.log4j.Logger;


public class FileDao extends TableDao {

	private static final long serialVersionUID = -7042815407707626319L;
	private static final Logger log = Logger.getLogger(FileDao.class);
	
	private static boolean tableCreated = false;
	
	private String name = "";
	private String date = "";
	private String size = "";
	private String path = "";

	public FileDao() {
		tableName = "file";
		createTableSql = "CREATE TABLE " + tableName + " (id int NOT NULL AUTO_INCREMENT, name varchar(64), date int, size int, path varchar(255), PRIMARY KEY (id))";
		if (!tableCreated) {
			if (createTable()) {
				tableCreated = true;
			}
		}
	}
	
	public void set(String name, String date, String size, String path) {
		insertSql = "INSERT INTO " + tableName + " (name,date,size,path) VALUES ('" + name + "','" + date + "','" + size + "','" + path + "')";
		this.name = name;
		this.date = date;
		this.size = size;
		this.path = path;
	}
	
	public String getName() {
		return name;
	}
	
	public String getDate() {
		return date;
	}
	
	public String getSize() {
		return size;
	}
	
	public String getPath() {
		return path;
	}
	
	@Override
	public String toString() {
		return "File [tableName=" + tableName + 
				", createTableSql=" + createTableSql + 
				", insertSql=" + insertSql + 
				", id=" + id +
				", name=" + name +
				", date=" + date +
				", size=" + size +
				", path=" + path +
				"]";
	}
	
	

}
