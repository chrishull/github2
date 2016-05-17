package co.spillikin.web.rest;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import co.spillikin.web.database.JdbcConnection;

/**
 * jax-rs resource.  Video Library service ping.
 * Talkg to MariaDB to insure connectivity.  Reports status.
 * 
 * @author chris
 *
 */
@Path("/status")
public class Video {

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String sayPlainTextHello() {
	  
		JdbcConnection jc = new JdbcConnection();
		String ss = jc.getSomething ();
		
    return "DB connect Video" + ss;
  }

  // This method is called if XML is request
  @GET
  @Produces(MediaType.TEXT_XML)
  public String sayXMLHello() {
		JdbcConnection jc = new JdbcConnection();
		String ss = jc.getSomething ();
		
    return "<?xml version=\"1.0\"?>" + "<hello> DB connect Video" + 
  ss + "</hello>";
  }
  // This method is called if HTML is request
  @GET
  @Produces(MediaType.TEXT_HTML)
  public String sayHtmlHello() {
	  
	JdbcConnection jc = new JdbcConnection();
	String ss = jc.getSomething ();
		
    return "<html> " + "<title>" + "DB connect Video	" + "</title>"
        + "<body><h1>" + "DB connect Video TEXT_HTML <p>" 
    
        + ss + "</body></h1>" + "</html> ";
  }

} 


