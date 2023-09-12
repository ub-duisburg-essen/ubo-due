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

    <xsl:variable name="solr_query" select="'q=status%3Aconfirmed'" />
    <xsl:variable name="numTotal" select="document(concat('solr:',$solr_query,'&amp;rows=0'))/response/result/@numFound" />

    <article class="card publication-stats">
      <div class="card-body">

        <h3 class="card-title">
          <xsl:value-of select="i18n:translate('ubo.card.publications.title')" />
        </h3>

        <ul class="list-group">
          <li class="mycore-list-item">
            <span class="mycore-facet-count">
              <xsl:value-of select="i18n:translate('ubo.card.publications.total')" />
            </span>
            <a href="{$ServletsBaseURL}solr/select?q=status:confirmed">
              <span class="mycore-facet-value">
                <xsl:value-of select="$numTotal"/>
              </span>
            </a>
          </li>
        </ul>

        <h4>
          <xsl:value-of select="i18n:translate('ubo.card.publications.perYear')" />
        </h4>
        <ul class="list-group">
          <xsl:for-each select="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='year']/int">
            <xsl:sort select="@name" data-type="number" order="descending" />
            <xsl:if test="position() &lt; 4">
              <li class="mycore-list-item">
                <span class="mycore-facet-count">
                  <xsl:value-of select="@name"/>
                </span>
                <a href="{$ServletsBaseURL}solr/select?q=status:confirmed+AND+year:{@name}">
                  <span class="mycore-facet-value">
                    <xsl:value-of select="text()"/>
                  </span>
                </a>
              </li>
            </xsl:if>
          </xsl:for-each>
        </ul>

        <h4>
          <xsl:value-of select="i18n:translate('ubo.card.publications.oa')" />
        </h4>
        <ul class="list-group">
          <xsl:for-each select="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='oa']/int">
            <xsl:variable name="oa_id" select="@name" />
            <li class="mycore-list-item">
              <span class="mycore-facet-count mycore-facet-count--oa-stats">
                <xsl:value-of select="$oa//category[@ID=$oa_id]/label[lang($CurrentLang)]/@text"/>
              </span>
              <a href="{$ServletsBaseURL}solr/select?q=status:confirmed+AND+oa:{$oa_id}">
                <span class="mycore-facet-value mycore-facet-count--oa-stats">
                  <xsl:value-of select="text()"/>
                </span>
              </a>
            </li>
          </xsl:for-each>
        </ul>
        <p class="mt-2">
          <a href="statistics.xml"><xsl:value-of select="i18n:translate('ubo.more')" />...</a>
        </p>
      </div>
    </article>
  </xsl:template>

</xsl:stylesheet>