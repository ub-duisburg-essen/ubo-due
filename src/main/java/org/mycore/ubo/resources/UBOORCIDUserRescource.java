package org.mycore.ubo.resources;

import java.util.List;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import org.mycore.frontend.jersey.MCRJerseyUtil;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

@Path("orcid-user")
public class UBOORCIDUserRescource {

    @GET
    @Path("list")
    public Response listAll() {
        List<MCRUser> orcidUsers = MCRUserManager.listUsers(
            null,null,null,null,"orcid_credential_",0,9999);

        // TODO how to make Resource admin-only?
        MCRJerseyUtil.checkPermission("manage-sessions");

        JsonArray rootJSON = orcidUsers.stream()
            .map(user -> {
                JsonObject userJSON = new JsonObject();

                userJSON.addProperty("userName", user.getUserName());
                userJSON.addProperty("realName", user.getRealName());

                JsonArray attributesJSON = new JsonArray();

                if (user.getAttributes() != null) {
                    user.getAttributes().forEach(attribute -> {
                        JsonObject attributeJSON = new JsonObject();

                        attributeJSON.addProperty("name", attribute.getName());
                        attributeJSON.addProperty("value", attribute.getValue());

                        attributesJSON.add(attributeJSON);
                    });
                }

                userJSON.add("attributes", attributesJSON);

                return userJSON;
            })
            .collect(
                JsonArray::new,
                JsonArray::add,
                JsonArray::addAll
            );

        return Response
            .status(Response.Status.OK)
            .type(MediaType.APPLICATION_JSON)
            .entity(rootJSON.toString())
            .build();
    }
}
