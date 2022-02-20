<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3">

  <!-- https://redmine.ub.uni-due.de/issues/4286 -->
  <!-- Use just "DuEPublico" as publisher -->

  <xsl:include href="copynodes.xsl" />
  
  <xsl:template match="mods:publisher[contains(text(),'DuEPublico')]">
    <mods:publisher>DuEPublico</mods:publisher>
  </xsl:template>

</xsl:stylesheet>
