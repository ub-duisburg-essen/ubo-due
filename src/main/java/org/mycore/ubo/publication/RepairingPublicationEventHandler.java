package org.mycore.ubo.publication;

import org.mycore.common.events.MCREvent;
import org.mycore.datamodel.metadata.MCRObject;

/**
 * Extends the default publication event handler to also act on repair events.
 * 
 * @author Frank
 */
public class RepairingPublicationEventHandler extends PublicationEventHandler {

    @Override
    protected void handleObjectRepaired(MCREvent evt, MCRObject obj) {
        super.handleObjectUpdated(evt, obj);
    }
}
