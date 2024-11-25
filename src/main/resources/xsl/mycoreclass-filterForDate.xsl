<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="copynodes.xsl" />
 
  <xsl:param name="UBO.VersionedClassification.MaxDate" />
  <xsl:param name="date" select="$UBO.VersionedClassification.MaxDate" />
  
  <xsl:variable name="dateAsNumber" select="number(translate($date,'-',''))" />
  
  <xsl:template match="valid">
    <xsl:if test="(not(@from) or (number(translate(@from,'-','')) &lt;= $dateAsNumber)) and (not(@until) or (number(translate(@until,'-','')) &gt;= $dateAsNumber))">
      <xsl:apply-templates select="*" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mycoreclass">
    <mycoreclass xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="MCRClassification.xsd">
      <xsl:apply-templates select="@ID|node()" />
    </mycoreclass>
  </xsl:template>
  
  <xsl:template match="mycoreclass/@ID">
    <xsl:attribute name="ID">
      <xsl:value-of select="." />

      <xsl:variable name="versions" select="document(concat('property:UBO.VersionedClassification.',.,'*'))/properties" />
      <xsl:variable name="legacyVersion" select="$versions/entry[contains(@key,'LegacyVersion')]" />
      
      <xsl:for-each select="$versions/entry[contains(@key,'.from')]">
        <xsl:variable name="version" select="substring-before(substring-after(@key,'.Version.'),'.')" />
        <xsl:variable name="from"  select="number(translate($versions/entry[contains(@key,concat($version,'.from'))],'-',''))" />
        <xsl:variable name="until" select="number(translate($versions/entry[contains(@key,concat($version,'.until'))],'-',''))" />
        
        <!-- is this the right version matching the given date? -->
        <xsl:if test="($from &lt;= $dateAsNumber) and ($until &gt;= $dateAsNumber) and (not($version = $legacyVersion))">
          <xsl:value-of select="concat('_',$version)" />
        </xsl:if>
      </xsl:for-each>
  
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>