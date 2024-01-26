package org.mycore.ubo.matcher;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.SortedSet;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jaxen.JaxenException;
import org.jdom2.Element;
import org.mycore.common.MCRException;
import org.mycore.common.xml.MCRNodeBuilder;
import org.mycore.mods.merger.MCRMerger;
import org.mycore.mods.merger.MCRMergerFactory;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserAttribute;
import org.mycore.user2.MCRUserManager;

/**
 * This class is same as MCRUserMatcherLocal from ubo-common,
 * except that there is a small bugfix in checking matching users,
 * that fix is not yet in the develop and main branches of ubo-common.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class UDEUserMatcherLocal implements MCRUserMatcher {

    private final static Logger LOGGER = LogManager.getLogger(UDEUserMatcherLocal.class);

    @Override
    public MCRUserMatcherDTO matchUser(MCRUserMatcherDTO matcherDTO) {

        MCRUser mcrUser = matcherDTO.getMCRUser();
        List<MCRUser> matchingUsers = new ArrayList<>(getUsersForGivenAttributes(mcrUser.getAttributes()));
        
        MCRMerger nameThatShouldMatch = buildNameMergerFrom(mcrUser);
        matchingUsers.removeIf( userToTest -> ! buildNameMergerFrom(userToTest).isProbablySameAs(nameThatShouldMatch) );
        
        if(matchingUsers.size() >= 1) {
            MCRUser matchingUser = matchingUsers.get(0);

            LOGGER.info("Found local matching user! Matched user: {} and attributes: {} with local user: {} and attributes: {}",
                    mcrUser.getUserName(),
                    mcrUser.getAttributes().stream().map(a -> a.getName() + "=" + a.getValue()).collect(Collectors.joining(" | ")),
                    matchingUser.getUserName(),
                    matchingUser.getAttributes().stream().map(a -> a.getName() + "=" + a.getValue()).collect(Collectors.joining(" | ")));

            // only add not attributes which are not present
            matchingUser.getAttributes()
                    .addAll(mcrUser.getAttributes().stream()
                            .filter(Predicate.not(matchingUser.getAttributes()::contains))
                            .collect(Collectors.toUnmodifiableList()));

            mcrUser = matchingUser;
            matcherDTO.setMCRUser(mcrUser);
            matcherDTO.setMatchedOrEnriched(true);
        }
        return matcherDTO;
    }

    private static final String XPATH_TO_BUILD_MODSNAME = "mods:name[@type='personal']/mods:namePart";
    
    private MCRMerger buildNameMergerFrom(MCRUser user) {
        Element nameElement = null;
        try {
            nameElement = new MCRNodeBuilder().buildElement(XPATH_TO_BUILD_MODSNAME, user.getRealName(), null);
        } catch (JaxenException shouldNeverOccur) {
            throw new MCRException(shouldNeverOccur);
        }
        return MCRMergerFactory.buildFrom(nameElement);
    }

    private Set<MCRUser> getUsersForGivenAttributes(SortedSet<MCRUserAttribute> mcrAttributes) {
        Set<MCRUser> users = new HashSet<>();
        for(MCRUserAttribute mcrAttribute : mcrAttributes) {
            String attributeName = mcrAttribute.getName();
            String attributeValue = mcrAttribute.getValue();
            users.addAll(MCRUserManager.getUsers(attributeName, attributeValue).collect(Collectors.toList()));
        }
        return users;
    }

}
