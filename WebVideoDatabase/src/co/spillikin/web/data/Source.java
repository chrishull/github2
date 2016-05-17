package co.spillikin.web.data;

/**
 * This bean represents the source of a video, such as
 * TV Show or Movie.  This forms a pop-up which is associated with 
 * meta data.
 * 
 * @author chris
 *
 */
public class Source implements java.io.Serializable {
	
	private static final long serialVersionUID = 7791693536427133712L;
	
	private Integer id;
	private String source;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getSource() {
		return source;
	}
	public void setSource(String source) {
		this.source = source;
	}
}
