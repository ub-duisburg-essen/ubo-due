<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="xsl">

  <xsl:output method="xml" />

  <xsl:template match="/entry">
    <mods:mods>
      <xsl:apply-templates select="docs/entry[1]/pnx" />
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="pnx">
    <xsl:apply-templates select="display/lds50" />
  </xsl:template>
  
  <xsl:param name="WebApplicationBaseURL" />
  
  <xsl:variable name="PeerReviewedURI" select="concat($WebApplicationBaseURL,'classifications/peerreviewed')" />
  
  <xsl:template match="lds50[contains(text(),'peer_reviewed')]">
    <mods:classification valueURI="{$PeerReviewedURI}#true" authorityURI="{$PeerReviewedURI}" />
  </xsl:template>
  
  <xsl:template match="@*|node()" />

</xsl:stylesheet>
