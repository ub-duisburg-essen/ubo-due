package org.mycore.ubo.lsf;

import org.jdom2.Element;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

public class LSFSearchServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        String queryString = job.getRequest().getQueryString();
        Element result = MCRURIResolver.instance().resolve("lsf:" + queryString);
        getLayoutService().sendXML(job.getRequest(), job.getResponse(), new MCRJDOMContent(result));
    }
}
