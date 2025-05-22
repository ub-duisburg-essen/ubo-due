package org.mycore.ubo.session;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;

/**
 * After successful login, the session timeout is restored to its default value, compare {@link HttpSession#getMaxInactiveInterval()}.
 * Counteracts {@link SessionTimeoutFilter} for logged-in users.
 */
public class SessionLoginFilter implements Filter {

    private static final Logger LOGGER = LogManager.getLogger();

    /** timeout length in seconds */
    private static final int DEFAULT_TIMEOUT_LENGTH = 1800;

    @Override
    public void doFilter(ServletRequest sreq, ServletResponse sres, FilterChain chain)
        throws IOException, ServletException {
        final HttpServletRequest request = (HttpServletRequest) sreq;
        try {
            chain.doFilter(sreq, sres);
        } finally {  // when loginServlet forwards, login was successful
            final HttpSession session = request.getSession(false);
            if (session != null && session.getMaxInactiveInterval() < DEFAULT_TIMEOUT_LENGTH) {
                session.setMaxInactiveInterval(DEFAULT_TIMEOUT_LENGTH);
                LOGGER.info("Session timeout was reset to " + DEFAULT_TIMEOUT_LENGTH + " seconds after successful login");
            }
        }
    }
}
