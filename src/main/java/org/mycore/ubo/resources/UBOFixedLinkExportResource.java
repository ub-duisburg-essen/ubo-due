package org.mycore.ubo.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.common.xml.MCRURIResolver;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Path("export-list")
public class UBOFixedLinkExportResource {

    private static final List<String> ROLES = MCRConfiguration2.getString("UBO.Search.PersonalList.Roles")
        .stream()
        .flatMap(MCRConfiguration2::splitValue)
        .collect(Collectors.toList());

    private static final Logger LOGGER = LogManager.getLogger();

    private static String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    protected static final String STATUS_RESTRICTION = MCRConfiguration2.getString("UBO.Export.Status.Restriction")
        .orElse("+status:confirmed");

    /**
     * Translates an ID into a Solr query with configured parameters. Then returns a response
     * with the transformed search result of the Solr query.
     * <p><p>
     * The configuration needed:
     * <ul>
     * <li>(obligatory) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>transformer</strong>=&lt;transformer to be used&gt;</li>
     * <li>(obligatory if 'tags' isn't configured) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>connection-ids</strong>=
     * &lt;comma-separated list of connection-ids&gt;</li>
     * <li>(obligatory if 'connection-ids' isn't configured) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>tags</strong>=
     * &lt;comma-separated list of tags&gt;</li>
     * <li>(optional) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>sort-fields</strong>=&lt;comma-separated list of sort fields&gt;</li>
     * <li>UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>sort-directions</strong>=&lt;comma-separated list of sort directions
     * (asc or desc)&gt;</li>
     * <li>(optional) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>year-from</strong>=&lt;year when to begin search&gt;</li>
     * <li>(optional) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>year-single</strong>=&lt;single year to search in&gt;</li>
     * <li>(optional, standard value is false) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.<strong>part-of</strong>=&lt;is part of
     * statistics, true or false&gt;</li>
     * </ul>
     * @param id the id with which the configuration is defined
     * @return the response with the transformed content of the Solr search or an error message
     */
    @GET
    @Path("{id}")
    public Response fixedSearch(@PathParam("id") String id) {

        Map<String, String> propertiesMap = MCRConfiguration2.getSubPropertiesMap(
            "UBO.Search.PersonalList.FixedSearch." + id + ".");
        if (propertiesMap.isEmpty()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        String connectionsIds = getOrNull(propertiesMap,"connection-ids");
        String tags = getOrNull(propertiesMap,"tags");
        String transformer = getOrNull(propertiesMap,"transformer");
        if ((connectionsIds == null && tags == null)
            || transformer == null) {
            return Response.status(Response.Status.BAD_REQUEST).entity(
                "Not all needed parameters for the query are configured").build();
        }
        if (connectionsIds != null && tags != null) {
            return Response.status(Response.Status.BAD_REQUEST).entity(
                "Configure either pids or tags").build();
        }

        if (MCRContentTransformerFactory.getTransformer(transformer) == null) {
            return Response.status(Response.Status.BAD_REQUEST).entity(
                "No valid transformer configured").build();
        }

        List<String> sortFields = new ArrayList<>(Arrays.asList(propertiesMap.get("sort-fields").split(",")));
        List<String> sortDirections = new ArrayList<>(Arrays.asList(propertiesMap.get("sort-directions").split(",")));
        Integer year = propertiesMap.get("year-from") == null || propertiesMap.get("year-from").isBlank() ? null :
                       Integer.parseInt(propertiesMap.get("year-from"));
        String yearSingle = getOrNull(propertiesMap, "year-single");
        Boolean partOf = propertiesMap.get("part-of") != null && !propertiesMap.get("part-of").isBlank()
            && Boolean.parseBoolean(propertiesMap.get("part-of"));

        if (sortFields.size() != sortDirections.size()) {
            return Response.status(Response.Status.BAD_REQUEST).build();
        }

        String yearPart;

        if (year != null) {
            yearPart = "+year:[" + year + " TO *] ";
        } else {
            yearPart = "";
        }

        if (yearSingle != null) {
            yearPart = "+year:" + yearSingle + " ";
        }

        String partOfPart = "";
        if (MCRConfiguration2.getBoolean("UBO.Editor.PartOf.Enabled").orElse(false) && partOf) {
            partOfPart = "+partOf:true ";
        }

        String solrQuery = UBOFixedLinkExportResource.STATUS_RESTRICTION + " " + yearPart + partOfPart;

        String childFilterQuery;
        StringBuilder solrRequest;
        if (connectionsIds != null) {
            Set<String> pids = Stream.of(connectionsIds.split(",")).collect(Collectors.toSet());
            String nidConnectionValue = "(" + String.join(" OR ", pids) + ")";
            childFilterQuery = "+name_id_connection:" + nidConnectionValue;
            if (!ROLES.isEmpty()) {
                childFilterQuery += " +role:(" + String.join(" OR ", ROLES) + ")";
            }

            solrQuery += "+{!parent which=\"objectType:mods\" filters=$childfq}objectKind:name";
            solrRequest = new StringBuilder()
                .append("q=").append(encode(solrQuery))
                .append("&childfq=").append(encode(childFilterQuery))
                .append("&rows=9999");
        } else {
            Set<String> tagsSplit = Stream.of(tags.split(",")).collect(Collectors.toSet());
            String tagValue = "(" + String.join(" OR ", tagsSplit) + ")";
            solrQuery += "+tag:" + tagValue;
            solrRequest = new StringBuilder()
                .append("q=").append(encode(solrQuery))
                .append("&rows=9999");
        }

        List<String> sorts = new ArrayList<>(sortFields.size());
        for (int i = 0; i < sortFields.size(); i++) {
            sorts.add(encode(sortFields.get(i) + " " + sortDirections.get(i)));
        }
        if (!sorts.isEmpty()) {
            solrRequest.append("&sort=");
            solrRequest.append(String.join(encode(", "), sorts));
        }

        LOGGER.info("Request is " + solrRequest);

        String uri = "solr:requestHandler:select2:" + solrRequest;
        Element source = MCRURIResolver.instance().resolve(uri);
        MCRJDOMContent content = new MCRJDOMContent(source);
        try {
            MCRContent transformed = MCRContentTransformerFactory.getTransformer(transformer).transform(content);
            return Response.ok(transformed.getContentInputStream()).build();
        } catch (Exception e) {
            LOGGER.error(e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Returns null when a property is not in a properties-map or is a blank property, else the value to the key.
     * @param propertiesMap the map to search in for a property
     * @param key the searched-for key
     * @return the value to the given key or null
     */
    private String getOrNull(Map<String, String> propertiesMap, String key) {
        return propertiesMap.get(key) == null || propertiesMap.get(key).isBlank() ? null : propertiesMap.get(key);
    }
}
