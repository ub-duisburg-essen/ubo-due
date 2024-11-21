<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="copynodes.xsl" />
  
  <xsl:param name="date" select="'2099-12'" />
  <xsl:variable name="dateAsNumber" select="number(translate($date,'-',''))" />
  
  <xsl:template match="valid">
    <xsl:if test="(not(@from) or (number(translate(@from,'-','')) &lt;= $dateAsNumber)) and (not(@until) or (number(translate(@until,'-','')) &gt;= $dateAsNumber))">
      <xsl:apply-templates select="*" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>