<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                exclude-result-prefixes="xsl mods">

  <xsl:import href="xslImport:solr-document:ubo-due-solr.xsl" />
  
  <xsl:variable name="origin" select="document('classification:metadata:-1:children:ORIGIN')/mycoreclass/categories" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    
    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:for-each select="mods:classification[contains(@authorityURI,'ORIGIN')]">
      
        <xsl:variable name="category" select="substring-after(@valueURI,'#')" />
        <xsl:for-each select="document(concat('classification:editor:0:parents:ORIGIN:',$category))/descendant::item">
          <field name="origin_unversioned">
            <xsl:choose>
              <xsl:when test="contains(@value,'_v')">
                <xsl:value-of select="substring-before(@value,'_v')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@value" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
        </xsl:for-each>
      
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
