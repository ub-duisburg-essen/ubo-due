<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="xsl xalan">

  <xsl:output method="text" encoding="UTF-8" media-type="text/plain" />
  
  <xsl:template match="/mycoreclass">
    <xsl:call-template name="header" />
    <xsl:apply-templates select="categories" />
  </xsl:template>
  
  <xsl:template name="header">
    <xsl:call-template name="value">
      <xsl:with-param name="value">lid</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">parentlid</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">orgunittype</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">shorttext</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">defaulttext</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">visibility</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">subjectArea</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">validFrom</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">validTo</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">description</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">longtext</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="value">
      <xsl:with-param name="value">sortorder</xsl:with-param>
      <xsl:with-param name="last" select="true()" />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="categories">
    <xsl:call-template name="value">
      <xsl:with-param name="value">ORIGIN</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="value" />

    <xsl:call-template name="value">
      <xsl:with-param name="value">Wurzel</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="value" />
    
    <xsl:call-template name="value">
      <xsl:with-param name="value">Aufbauorganisation Universitätsbibliographie</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="value">
      <xsl:with-param name="value">public</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="value">
      <xsl:with-param name="value">ohne</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="value" />
    
    <xsl:call-template name="value" />
    
    <xsl:call-template name="value" />
    
    <xsl:call-template name="value" />
    
    <xsl:call-template name="value">
      <xsl:with-param name="value">1</xsl:with-param>
      <xsl:with-param name="last" select="true()" />
    </xsl:call-template>

    <xsl:apply-templates select="category" />
  </xsl:template>
  
  <xsl:template match="category">
    <xsl:call-template name="value">
      <xsl:with-param name="value" select="@ID" />
    </xsl:call-template>

    <xsl:call-template name="value">
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="parent::category">
            <xsl:value-of select="parent::category/@ID" />
          </xsl:when>
          <xsl:otherwise>ORIGIN</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="value">
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="label[contains(@text,'Fakultät')]">Fak./Fb.</xsl:when>
          <xsl:when test="label[contains(@text,'Institut')]">Institut</xsl:when>
          <xsl:when test="label[contains(@text,'Klinik')]">Klinik</xsl:when> 
          <xsl:when test="ancestor::category[@ID='ZE']">zentr. HsEinr.</xsl:when>
          <xsl:when test="ancestor::category[@ID='ZWE']">zentr. HsEinr.</xsl:when>
          <xsl:when test="ancestor::category[@ID='LV']">zentr. HsEinr.</xsl:when>
          <xsl:when test="@ID='SE'">ext. Einr.</xsl:when>
          <xsl:when test="@ID='REKT'">Leitung</xsl:when>
          <xsl:when test="category">Sektion</xsl:when>
          <xsl:otherwise>Lehrstuhl</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="value" />

    <xsl:call-template name="value">
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="label[lang('de')]">
            <xsl:value-of select="label[lang('de')]/@text" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="label[1]/@text" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="value">
      <xsl:with-param name="value">public</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="value">
      <xsl:with-param name="value">ohne</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="value" />

    <xsl:call-template name="value" />

    <xsl:call-template name="value" />

    <xsl:call-template name="value" />

    <xsl:call-template name="value">
      <xsl:with-param name="value" select="position()" />
      <xsl:with-param name="last" select="true()" />
    </xsl:call-template>
    
    <xsl:apply-templates select="category" />
  </xsl:template>
  
  <xsl:template name="value">
    <xsl:param name="value" />
    <xsl:param name="last" select="false()" />
    
    <xsl:if test="string-length($value) &gt; 0">
      <xsl:variable name="anf">"</xsl:variable>
      <xsl:text>"</xsl:text>
      <xsl:for-each select="xalan:tokenize($value,$anf)">
        <xsl:if test="position() != 1">\"</xsl:if>
        <xsl:value-of select="." />
        <xsl:if test="(position() != 1) and (position() = last())">\"</xsl:if>
      </xsl:for-each>
      <xsl:text>"</xsl:text>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="not(boolean($last))">;</xsl:when>
      <xsl:otherwise>
        <xsl:text>
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>