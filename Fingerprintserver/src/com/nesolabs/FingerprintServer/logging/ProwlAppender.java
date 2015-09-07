package com.nesolabs.FingerprintServer.logging;

import net.sourceforge.prowl.api.DefaultProwlEvent;
import net.sourceforge.prowl.api.ProwlClient;
import net.sourceforge.prowl.api.ProwlEvent;
import net.sourceforge.prowl.exception.ProwlException;

import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.spi.LoggingEvent;

public class ProwlAppender extends AppenderSkeleton {

	@Override
	public void close() {
		// nothing to do here
	}

	@Override
	public boolean requiresLayout() {
		return true;
	}

	@Override
	protected void append(LoggingEvent event) {
		// Send message
		ProwlClient client = new ProwlClient();
		ProwlEvent e = new DefaultProwlEvent(
				"<APKIKEY>", "FingerprintServer", "ERROR (FS)",
				event.getMessage() + "\n" + event.getLocationInformation().getClassName() + "." + event.getLocationInformation().getMethodName() + ": #" + event.getLocationInformation().getLineNumber(), 2);
		try {
			client.pushEvent(e);
		} catch (ProwlException e1) {
			e1.printStackTrace();
		}

	}

}
