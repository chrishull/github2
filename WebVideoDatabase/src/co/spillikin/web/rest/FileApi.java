package co.spillikin.web.rest;

import java.util.ArrayList;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.apache.log4j.Logger;

import co.spillikin.web.data.File;

/**
 * Thisis the REST API for handling Video files.
 * 
 * @author chris
 *
 */
@Path("/file")
public class FileApi {
	
	private static final Logger log = Logger.getLogger(File.class);

	@GET
	@Path("/get")
	// @Produces(MediaType.TEXT_HTML)
	@Produces(MediaType.APPLICATION_JSON)
	public File getFile() {
		
		File f1 = new File();
		f1.setDate("same date 1");
		f1.setName("Video name 1");
		f1.setPath("path to file");
		f1.setSize("1234");
		log.info("Get file " + f1);
		return f1;
		
	}
	
	/**
	 * Create a new videotape record.
	 * 
	 * @param file
	 * @return
	 */
	@Path("/create")
    @PUT
    // @Path("{internalNetworkId}")
    @Produces({MediaType.APPLICATION_JSON })
    @Consumes({MediaType.APPLICATION_JSON })
	public File setFile(File file ){
    	
		log.info("Creating new file " + file.getName() );
    		return file;
		
	}
			
			

} 
