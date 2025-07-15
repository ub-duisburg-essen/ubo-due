<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xalan i18n">

  <xsl:include href="mycoreclass-versioned-labels.xsl" />
  
  <xsl:key name="categories" match="category" use="@ID" />
  
  <xsl:template match="category/@ID">
    <xsl:variable name="id" select="." />
    <xsl:attribute name="ID">
      <xsl:value-of select="." />
      <xsl:if test="count(key('categories',$id)) &gt; 1">
        <xsl:apply-templates select="ancestor::valid[1]" mode="id" />
      </xsl:if>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="valid" mode="id">
    <xsl:choose>
      <xsl:when test="@from">
        <xsl:call-template name="output_version">
          <xsl:with-param name="date" select="@from" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@until">
        <xsl:call-template name="output_version">
          <xsl:with-param name="date" select="@until" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:variable name="classifID" select="/mycoreclass/@ID" />
  <xsl:variable name="properties" select="document(concat('property:UBO.VersionedClassification.',$classifID,'*'))/properties" />
  <xsl:variable name="legacyVersion" select="$properties/entry[contains(@key,'LegacyVersion')]" />

  <xsl:template name="output_version">
    <xsl:param name="date" />
    <xsl:variable name="dateAsNumber" select="number(translate($date,'-',''))" />
    
    <xsl:for-each select="$properties/entry[contains(@key,'.from')]">
      <xsl:variable name="version" select="substring-before(substring-after(@key,'.Version.'),'.')" />
      <xsl:variable name="from"  select="number(translate($properties/entry[contains(@key,concat($version,'.from'))],'-',''))" />
      <xsl:variable name="until" select="number(translate($properties/entry[contains(@key,concat($version,'.until'))],'-',''))" />
      
      <xsl:if test="($from &lt;= $dateAsNumber) and ($until &gt;= $dateAsNumber) and (not($version = $legacyVersion))">
        <xsl:value-of select="concat('_',$version)" />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>