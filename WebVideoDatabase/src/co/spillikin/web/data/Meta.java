package co.spillikin.web.data;

/**
 * Meta is the outermost container for a piece of media / video.
 * It contains elements of it's onw, and references to 
 * things like Genre, Source, and File.
 * 
 * @author chris
 *
 */
public class Meta implements java.io.Serializable {

	private static final long serialVersionUID = -3348613606701179944L;
	
	private Integer id;
	private String title;
	private String description;
	private Integer fileTableId;
	private Integer genreTableId;
	private Integer sourceTableId;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public Integer getFileTableId() {
		return fileTableId;
	}
	public void setFileTableId(Integer fileTableId) {
		this.fileTableId = fileTableId;
	}
	public Integer getGenreTableId() {
		return genreTableId;
	}
	public void setGenreTableId(Integer genreTableId) {
		this.genreTableId = genreTableId;
	}
	public Integer getSourceTableId() {
		return sourceTableId;
	}
	public void setSourceTableId(Integer sourceTableId) {
		this.sourceTableId = sourceTableId;
	}
}
