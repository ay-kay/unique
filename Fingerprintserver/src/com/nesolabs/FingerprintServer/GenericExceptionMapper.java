package com.nesolabs.FingerprintServer;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;



@Provider
public class GenericExceptionMapper implements ExceptionMapper<Exception> {
	
	public Response toResponse(Exception ex) {
		
		if (!(ex instanceof javax.ws.rs.WebApplicationException)) {
			Response res = Response.status(500).entity(new com.nesolabs.FingerprintServer.model.Response(true, ex.getMessage())).type("application/json").build();
			return res;
		} else {
			WebApplicationException e = (WebApplicationException) ex;
			return e.getResponse();
		}
	}
	
}
