package org.mycore.ubo.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.frontend.MCRFrontendUtil;

import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Path("export-fixed")
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
     * Translates an ID into a Solr query with configured parameters. Then returns a Response
     * with a redirect to the Solr query.
     * <p><p>
     * The configuration needed:
     * <ul>
     * <li>(obligatory) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.format=&lt;wanted format, ex. html&gt;</li>
     * <li>(obligatory if 'tags' isn't configured) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.connection-ids=
     * &lt;comma-separated list of connection-ids&gt;</li>
     * <li>(obligatory if 'connection-ids' isn't configured) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.tags=
     * &lt;comma-separated list of tags&gt;</li>
     * <li>(optional) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.sort-fields=&lt;comma-separated list of sort fields&gt;</li>
     * <li>UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.sort-directions=&lt;comma-separated list of sort directions
     * (asc or desc)&gt;</li>
     * <li>(optional) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.year-from=&lt;year where to begin search&gt;</li>
     * <li>(optional) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.year-single=&lt;single year to search in&gt;</li>
     * <li>(optional) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.style=&lt;wanted style, ex. ieee&gt;</li>
     * <li>(optional, standard value is false) UBO.Search.PersonalList.FixedSearch.&lt;id&gt;.part-of=&lt;is part of
     * statistics, true or false&gt;</li>
     * </ul>
     * @param id the id with which the configuration is defined
     * @return a redirect Response to the Solr query
     * @throws URISyntaxException in case of a malformed URI
     */
    @GET
    @Path("{id}")
    public Response fixedSearch(@PathParam("id") String id) throws URISyntaxException {
        Map<String,String> propertiesMap = MCRConfiguration2.getSubPropertiesMap(
            "UBO.Search.PersonalList.FixedSearch." + id + ".");
        if (propertiesMap.isEmpty()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        if ((!propertiesMap.containsKey("connection-ids") && !propertiesMap.containsKey("tags"))
            || !propertiesMap.containsKey("format")) {
            return Response.status(Response.Status.BAD_REQUEST).entity(
                "Not all needed parameters for the query are configured").build();
        }
        if (propertiesMap.containsKey("connection-ids") && propertiesMap.containsKey("tags")) {
            return Response.status(Response.Status.BAD_REQUEST).entity(
                "Configure either pids or tags").build();
        }

        String format = getOrNull(propertiesMap, "format");
        List<String> sortFields = new ArrayList<>(Arrays.asList(propertiesMap.get("sort-fields").split(",")));
        List<String> sortDirections = new ArrayList<>(Arrays.asList(propertiesMap.get("sort-directions").split(",")));
        Integer year = propertiesMap.get("year-from") == null || propertiesMap.get("year-from").isBlank() ? null :
                       Integer.parseInt(propertiesMap.get("year-from"));
        String yearSingle = getOrNull(propertiesMap, "year-single");
        String style = getOrNull(propertiesMap, "style");
        Boolean partOf = propertiesMap.get("part-of") == null || propertiesMap.get("part-of").isBlank() ? null :
                         Boolean.parseBoolean(propertiesMap.get("part-of"));


        if (sortFields.size() != sortDirections.size()) {
            return Response.status(Response.Status.BAD_REQUEST).build();
        }

        String baseURL = MCRFrontendUtil.getBaseURL();
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
        if (propertiesMap.containsKey("connection-ids")) {
            Set<String> pids = Stream.of(propertiesMap.get("connection-ids").split(",")).collect(Collectors.toSet());
            String nidConnectionValue = "(" + String.join(" OR ", pids) + ")";
            childFilterQuery = "+name_id_connection:" + nidConnectionValue;
            if (!ROLES.isEmpty()) {
                childFilterQuery += " +role:(" + String.join(" OR ", ROLES) + ")";
            }

            solrQuery += "+{!parent which=\"objectType:mods\" filters=$childfq}objectKind:name";
            solrRequest = new StringBuilder()
                .append(baseURL).append("servlets/solr/select2")
                .append("?q=").append(encode(solrQuery))
                .append("&childfq=").append(encode(childFilterQuery))
                .append("&rows=9999");
        }
        else {
            Set<String> tags = Stream.of(propertiesMap.get("tags").split(",")).collect(Collectors.toSet());
            String tagValue = "(" + String.join(" OR ", tags) + ")";
            solrQuery += "+tag:" + tagValue;
            solrRequest = new StringBuilder()
                .append(baseURL).append("servlets/solr/select2")
                .append("?q=").append(encode(solrQuery))
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

        if (style == null) {
            solrRequest.append("&XSL.Transformer=").append(encode(format));
        } else {
            solrRequest.append("&XSL.Transformer=response-csl-").append(encode(format));
            solrRequest.append("&XSL.style=").append(encode(style));
        }

        if (format.equals("mods2csv2")) {
            String s = MCRConfiguration2.getString("UBO.Export.Fields").get();
            solrRequest.append("&fl=").append(s);
        }

        LOGGER.info("Request is " + solrRequest);
        URI newLocation = new URI(solrRequest.toString());
        return Response.temporaryRedirect(newLocation).build();

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
