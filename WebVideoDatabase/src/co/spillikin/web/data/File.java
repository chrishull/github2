package co.spillikin.web.data;

/**
 * This bean represents a physical media file.
 */
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "file")
public class File implements java.io.Serializable {
	
	private static final long serialVersionUID = -7042815407707626319L;
	
	private Integer id;
	private String name = "";
	private String date = "";
	private String size = "";
	private String path = "";
	
	@XmlElement(name = "name")
	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	@XmlElement(name = "date")
	public String getDate() {
		return date;
	}
	
	public void setDate(String date) {
		this.date = date;
	}
	
	@XmlElement(name = "size")
	public String getSize() {
		return size;
	}
	public void setSize(String size) {
		this.size = size;
	}
	
	@XmlElement(name = "path")
	public String getPath() {
		return path;
	}
	
	public void setPath(String path) {
		this.path = path;
	}
	
	@XmlElement(name = "id")
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}
	
	public String toString() {
		return " path: " + path + " name: " + name + " size: " + size + 
			"date: " + date;
	}
}
