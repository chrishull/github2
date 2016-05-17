package co.spillikin.web.data;

/**
 * This bean represents a Genre for a media file, such as sci-fi or comedy.
 * It is a pop up and associated with meta data.
 * @author chris
 *
 */
public class Genre implements java.io.Serializable {

	private static final long serialVersionUID = 4491501862099149291L;
	
	private Integer id;
	private String genre;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getGenre() {
		return genre;
	}
	public void setGenre(String genre) {
		this.genre = genre;
	}
	
	
}
