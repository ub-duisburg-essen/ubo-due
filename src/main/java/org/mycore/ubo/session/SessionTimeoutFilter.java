package org.mycore.ubo.session;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.mcrimpl.MCRIPAddress;
import org.mycore.common.config.MCRConfiguration2;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * Decreases session time for all requests from all IP-addresses not registered in the allowlist MCR.Filter.SessionTimeout.Allowlist
 */
public class SessionTimeoutFilter implements Filter {

    private static final Logger LOGGER = LogManager.getLogger();

    private static List<MCRIPAddress> allowlist;

    /** timeout length in seconds */
    private static final int TIMEOUT_LENGTH = MCRConfiguration2
        .getOrThrow("MCR.Filter.SessionTimeout.TimeoutLength", Integer::parseInt);

    @Override
    public void init(final FilterConfig arg0) {
        final String allowlistAll = MCRConfiguration2.getString("MCR.Filter.SessionTimeout.Allowlist").orElse("");
            allowlist = Arrays.stream(allowlistAll.split(","))
                .map(String::trim)
                .map(this::createAddress)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    @Override
    public void doFilter(ServletRequest sreq, ServletResponse sres, FilterChain chain)
        throws IOException, ServletException {
        final HttpServletRequest request = (HttpServletRequest) sreq;

        final boolean newSession = request.getSession(false) == null;
        try {
            chain.doFilter(sreq, sres);
        } finally {
            final HttpSession session = request.getSession(false);
            if (session != null && newSession) {
                String clientIp = request.getRemoteAddr();
                try {
                    MCRIPAddress mcrIpAddressClient = new MCRIPAddress(clientIp);
                    if (!isAllowedIp(mcrIpAddressClient)) {
                        session.setMaxInactiveInterval(TIMEOUT_LENGTH);
                        LOGGER.debug(String.format("Session with client-IP " + clientIp + " expires in " + TIMEOUT_LENGTH +" seconds"));
                    }
                    else {
                        LOGGER.debug(String.format("Session with client-IP " + clientIp + " won't expire prematurely, because it's in the allowlist"));
                    }
                } catch (UnknownHostException e) {
                    LOGGER.warn("Invalid remote address: {}", clientIp);
                }

            }
        }
    }

    private boolean isAllowedIp(MCRIPAddress ip) {
        for (MCRIPAddress allowlistIp : allowlist) {
            if (Arrays.equals(allowlistIp.getAddress(), ip.getAddress())
            || allowlistIp.contains(ip)) {
                return true;
            }
        }
        return false;
    }

    private MCRIPAddress createAddress(String ip) {
        if (ip == null || ip.isEmpty()) {
            return null;
        }
        try {
            return new MCRIPAddress(ip);
        } catch (UnknownHostException e) {
            LOGGER.error("Invalid remote address: {}", e.getMessage());
            return null;
        }
    }
}
