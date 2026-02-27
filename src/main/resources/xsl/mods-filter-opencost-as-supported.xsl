<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl"
>

<xsl:template match="mods:extension[@type='openCost']">
  <xsl:copy>
    <xsl:copy-of select="@*|node()" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
