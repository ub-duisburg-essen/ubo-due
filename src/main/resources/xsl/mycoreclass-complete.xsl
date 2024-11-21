<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:math="http://exslt.org/math">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="valid">
    <xsl:apply-templates select="*" />
  </xsl:template>

  <xsl:template match="label[not(starts-with(@text,'x-'))]">
    <xsl:copy>
    <xsl:copy-of select="@*[not(name()='text')]" />
    
    <xsl:variable name="valids" select="parent::valid|../parent::valid" />
    
    <xsl:attribute name="text">
    
      <xsl:value-of select="@text" />
      <xsl:text> </xsl:text>
      
      <xsl:if test="count($valids) &gt; 0">
        <xsl:text> (</xsl:text>
        
        <xsl:if test="$valids[@from][1]">
          <xsl:text>ab </xsl:text>
          <xsl:value-of select="$valids[@from][1]/@from" />
        </xsl:if>
        
        <xsl:if test="$valids[@until]">
          <xsl:if test="$valids[@from]">
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:text>bis </xsl:text>
          <xsl:value-of select="$valids[@until][1]/@until" />
        </xsl:if>
        
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:attribute>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>