<?xml version="1.0" encoding="UTF-8"?>

<!-- Post-processor for search form -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="copynodes.xsl" />
  
  <!-- Remove version information from search field origin_unversioned -->
  <xsl:template match="condition[@field='origin_unversioned']/value[contains(text(),'_v')]">
    <xsl:copy>
      <xsl:value-of select="substring-before(text(),'_v')" />
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
