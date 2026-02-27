<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:opencost="https://opencost.de"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl">

  <xsl:output method="xml" />

  <xsl:template match="/opencost:publication[opencost:cost_data]">
    <mods:mods>
      <mods:extension type="openCost">
        <xsl:copy-of select="opencost:cost_data" />
      </mods:extension>
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="@*|node()" />

</xsl:stylesheet>
