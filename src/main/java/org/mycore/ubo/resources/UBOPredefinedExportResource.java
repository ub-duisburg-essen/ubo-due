package org.mycore.ubo.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.common.xml.MCRURIResolver;

@Path("export-list")
public class UBOPredefinedExportResource {

    private static final Logger LOGGER = LogManager.getLogger();

    /**
     * Takes an id, executes the corresponding configured Solr-query and returns it.
     * @param id the id with which the configuration is defined
     * @return the response with the transformed content of the Solr search or an error message
     */
    @GET
    @Path("{id}")
    public Response predefinedExport(@PathParam("id") String id) {

        String solrURI, solrRequest, transformerName;
        try {
            solrURI = MCRConfiguration2.getStringOrThrow("UBO.PredefinedExport." + id + ".DefaultSOLRURI");
            solrRequest = MCRConfiguration2.getStringOrThrow("UBO.PredefinedExport." + id + ".SolrRequest");
            transformerName = MCRConfiguration2.getStringOrThrow("UBO.PredefinedExport." + id + ".Transformer");
        } catch (MCRConfigurationException e) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        String uri = solrURI + solrRequest;
        LOGGER.info("Request is: {}", uri);
        Element source = MCRURIResolver.instance().resolve(uri);
        MCRJDOMContent content = new MCRJDOMContent(source);
        try {
            MCRContentTransformer transformer = MCRContentTransformerFactory.getTransformer(transformerName);
            MCRContent transformed = transformer.transform(content);
            return Response.ok(transformed.getContentInputStream()).build();
        } catch (Exception e) {
            LOGGER.error(e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

}
