package org.mycore.ubo.lsf;

import java.net.URL;
import java.util.Scanner;
import java.util.SortedSet;
import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.ubo.picker.PersonSearchResult;
import org.mycore.ubo.picker.PersonSearchResult.PersonResult;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserAttribute;
import org.mycore.user2.MCRUserManager;

/**
 * Adds the LSF ID to existing MCRUSer, if not yet present.
 * Assumes the MCRUser's userName is the login ID.
 *
 * @author Frank L\u00FCtzenkirchen
 */
@MCRCommandGroup(
    name = "LSF Commands")
public class User2LSFHelper {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String ATTR_ID_LSF = "id_lsf";

    private static final String TYPE_UID = "KENNUNG";

    private static final String TYPE_LSF = "LSF";

    private static final String URL_PATTERN = "https://benutzerverwaltung.uni-duisburg-essen.de/aid/?request_type=%s&request_value=%s";

    private static final Pattern AID_PATTERN = Pattern.compile("AID:(\\d+)");

    private static final int AID_SEARCH_HORIZON = 100;

    @MCRCommand(
        syntax = "discover LSF ID of user {0}",
        help = "Uses identity management of UDE to find the LSF ID for the given user {0}. Sets the LSF ID as user attribute, if not yet present.",
        order = 10)
    public static void discoverLSFIDofUser(String userID) throws Exception {
        MCRUser user = MCRUserManager.getUser(userID);
        discoverLSFIDof(user);
        LOGGER.info("LSF ID of user is now " + getLSFID(user));
    }

    @MCRCommand(
        syntax = "set LSF ID of user {0} to {1}",
        help = "Sets the LSF ID {1} of user {0} as user attribute.",
        order = 10)
    public static void setLSFIDofUser(String userID, String lsfID) throws Exception {
        MCRUser user = MCRUserManager.getUser(userID);
        setLSFID(user, lsfID);
        System.out.println("LSF ID of user is now " + getLSFID(user));
    }

    public static void discoverLSFIDof(MCRUser user) throws Exception {
        if (hasLSFID(user))
            return;

        String userName = user.getUserName();
        LOGGER.debug("user = " + userName);

        String aid_uid = getAID(TYPE_UID, userName);
        LOGGER.info("aid = " + aid_uid);

        if (aid_uid == null)
            return;

        PersonSearchResult psr = getPersonDataFromLSF(user);
        String lsfID = findMatchingLSFID(psr, aid_uid);

        LOGGER.info("LSF ID = " + lsfID);

        if (lsfID == null)
            return;

        setLSFID(user, lsfID);
    }

    private static boolean hasLSFID(MCRUser user) {
        String lsfID = getLSFID(user);
        return (lsfID != null) && !lsfID.isEmpty();
    }

    private static String getLSFID(MCRUser user) {
        return user.getUserAttribute(ATTR_ID_LSF);
    }

    private static String getAID(String type, String value) {
        String url = String.format(URL_PATTERN, type, value);
        Scanner scanner = null;
        try {
            scanner = new Scanner(new URL(url).openStream());
            scanner.findWithinHorizon(AID_PATTERN, AID_SEARCH_HORIZON);
            return scanner.match().group(1);
        } catch (Exception ex) {
            LOGGER.warn("Exception getting AID from " + url, ex);
            return null;
        } finally {
            if (scanner != null)
                scanner.close();
        }
    }

    private static PersonSearchResult getPersonDataFromLSF(MCRUser user) {
        String name = user.getRealName();
        return new LSFService().searchPerson(name);
    }

    private static String findMatchingLSFID(PersonSearchResult psr, String aid_uid) {
        if (psr.count == 0)
            LOGGER.info("no matching people found");

        for (PersonResult pr : psr.personList) {
            String lsfID = pr.pid;
            LOGGER.debug("checking LSF ID " + lsfID);
            String aid_lsf = getAID(TYPE_LSF, lsfID);
            LOGGER.info("AID for LSF ID " + lsfID + " = " + aid_lsf);
            if (aid_uid.equals(aid_lsf))
                return lsfID;
        }
        return null;
    }

    private static void setLSFID(MCRUser user, String lsfID) {
        SortedSet<MCRUserAttribute> userAttributes = user.getAttributes();

        if ((lsfID == null) || lsfID.equals("null")) {
            userAttributes.stream()
                .filter((attr) -> attr.getName().equals(ATTR_ID_LSF))
                .findFirst()
                .ifPresent(userAttributes::remove);
        } else {
            userAttributes.add(new MCRUserAttribute(ATTR_ID_LSF, lsfID));
        }

        user.setAttributes(userAttributes);
    }
}
