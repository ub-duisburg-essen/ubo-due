<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl mods xalan i18n">

  <xsl:include href="mods-display.xsl" />
  <xsl:include href="coreFunctions.xsl" />

  <xsl:param name="ServletsBaseURL" />

  <xsl:template match="/response">
    <article class="card">
      <div class="card-body">
        <strong>
          <xsl:value-of select="i18n:translate('ubo.newest')" />
        </strong>
        <xsl:for-each select="result[@name='response']">
          <ul class="list-group">
            <xsl:for-each select="doc">
              <li class="list-group-item">
                <xsl:variable name="id" select="str[@name='id']" />
                <xsl:variable name="mycoreobject" select="document(concat('mcrobject:',$id))/mycoreobject" />
                <div class="content bibentry ubo-hover-pointer" title="{i18n:translate('button.show')}" onclick="location.assign('{$WebApplicationBaseURL}servlets/DozBibEntryServlet?mode=show&amp;id={$id}');">
                  <xsl:apply-templates select="$mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" mode="cite">
                    <xsl:with-param name="mode">divs</xsl:with-param>
                  </xsl:apply-templates>
                </div>
              </li>
            </xsl:for-each>
          </ul>
          <xsl:variable name="year" select="doc[1]/int[@name='year']" />
          <p>
          <a href="{$ServletsBaseURL}solr/select?q=status:confirmed+AND+year:%5B{$year - 1}+TO+*%5D&amp;sort=year+desc,created+desc">
              <xsl:value-of select="i18n:translate('ubo.more')" />...
            </a>
          </p>
        </xsl:for-each>
      </div>
    </article>
  </xsl:template>

</xsl:stylesheet>
