<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xalan i18n">

  <xsl:include href="copynodes.xsl" />
  
  <xsl:param name="buildVersionedCategoryIDs" select="'true'" />

  <xsl:template match="mycoreclass">
    <mycoreclass xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="MCRClassification.xsd">
      <xsl:apply-templates select="@ID|node()" />
    </mycoreclass>
  </xsl:template>
  
  <xsl:template match="valid">
    <xsl:apply-templates select="*" />
  </xsl:template>
  
  <xsl:template match="category/@ID[$buildVersionedCategoryIDs = 'true']">
    <xsl:attribute name="ID">
      <xsl:value-of select="." />
      <xsl:apply-templates select="ancestor::valid[1]" mode="id" />
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="valid" mode="id">
    <xsl:text>_v</xsl:text>
    <xsl:choose>
      <xsl:when test="@until">
        <xsl:copy-of select="translate(substring(@until,3,5),'-','')" />
      </xsl:when>
      <xsl:when test="@from">
        <xsl:copy-of select="translate(substring(@from,3,5),'-','')" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="label[not(starts-with(@xml:lang,'x-'))]/@text">
    <xsl:attribute name="text">
      <xsl:value-of select="." />
      <xsl:apply-templates select="parent::label/parent::category/parent::valid" mode="label" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="valid[@until]" mode="label">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="i18n:translate('ubo.classification.versioning.until')" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="substring(@until,6,2)" />
    <xsl:text>/</xsl:text>
    <xsl:value-of select="substring(@until,1,4)" />
    <xsl:text>)</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>