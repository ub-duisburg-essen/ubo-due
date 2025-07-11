<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
        <xsl:copy-of select="translate(@until,'-','')" />
      </xsl:when>
      <xsl:when test="@from">
        <xsl:copy-of select="translate(@from,'-','')" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="label[not(starts-with(@lang,'x-'))]/@text">
    <xsl:attribute name="text">
      <xsl:value-of select="." />
      <xsl:apply-templates select="parent::label/parent::category/parent::valid" mode="label" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="valid" mode="label">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="@from|@until" mode="label" />
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="@from" mode="label">
    <xsl:value-of select="concat('ab ',.)" />
  </xsl:template>

  <xsl:template match="@until" mode="label">
    <xsl:if test="../@from"> </xsl:if>
    <xsl:value-of select="concat('bis ',.)" />
  </xsl:template>

</xsl:stylesheet>