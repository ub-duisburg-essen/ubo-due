<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="xsl str"
>

  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="numParentLabels" select="0" />
  <xsl:param name="subtext" />

  <xsl:param name="UBO.ClassificationOutput.MaxWords" select="4" />
  <xsl:param name="UBO.ClassificationOutput.MaxWordLength" select="10" />

  <xsl:variable name="dot" select="'.'" />
  <xsl:variable name="dots" select="'&#8230;'" />
  <xsl:variable name="nbsp" select="'&#160;'" />
  <xsl:variable name="arrow" select="'&#187;'" />
  <xsl:variable name="parentChildDelimiter" select="concat($nbsp,$arrow,' ')" />

  <xsl:template match="/mycoreclass">
    <includes>
      <xsl:apply-templates select="categories/category" />
    </includes>
  </xsl:template>
  
  <xsl:template match="category">
    <xsl:param name="parentTitle" />
    <xsl:param name="indent" />
    <xsl:param name="level" select="1" />
    
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label" />
    </xsl:variable>
    
    <xsl:variable name="title">
      <xsl:if test="$level &gt; 1">
        <xsl:value-of select="concat($parentTitle,$parentChildDelimiter)" />
      </xsl:if>
      <xsl:value-of select="$label" />
    </xsl:variable>
    
    <option value="{@ID}">
      <xsl:choose>
        <xsl:when test="($subtext = 'true') and ($level &gt; 1)">
          <xsl:attribute name="data-subtext">
            <xsl:value-of select="concat($nbsp,$nbsp,'in ',$parentTitle)" />
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="title">
            <xsl:value-of select="$title" />
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    
      <xsl:choose>
        <xsl:when test="($numParentLabels &gt; 0) and (($level - $numParentLabels) &gt; 1)">
          <xsl:for-each select="str:tokenize($indent,$arrow)">
            <xsl:if test="position() &gt;= ($level - $numParentLabels)">
              <xsl:value-of select="." />
              <xsl:if test="position() != last()">
                <xsl:value-of select="$arrow" />
              </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$indent" />
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:call-template name="abbreviate">
        <xsl:with-param name="label" select="$label" />
      </xsl:call-template>
    </option>
    
    <xsl:apply-templates select="category">
      <xsl:with-param name="level" select="$level + 1" />
      <xsl:with-param name="parentTitle" select="$title" />
      <xsl:with-param name="indent">
        <xsl:choose>
        
          <xsl:when test="$numParentLabels &gt; 0">
            <xsl:value-of select="$indent" />
            <xsl:apply-templates select="." mode="label-abbreviated">
              <xsl:with-param name="maxLength" select="$UBO.ClassificationOutput.MaxWordLength" />
            </xsl:apply-templates>
            <xsl:value-of select="$parentChildDelimiter" />
          </xsl:when>

          <xsl:otherwise> <!-- default: spaces -->
            <xsl:value-of select="concat($indent,$nbsp,$nbsp,$nbsp,$nbsp)" />
          </xsl:otherwise>
          
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template match="category" mode="label">
    <xsl:choose>
      <xsl:when test="label[lang($CurrentLang)]">
        <xsl:value-of select="label[lang($CurrentLang)]/@text" />
      </xsl:when>
      <xsl:when test="label[lang($DefaultLang)]">
        <xsl:value-of select="label[lang($DefaultLang)]/@text" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="label[not(starts-with(@lang,'x-'))][1]/@text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="category" mode="label-abbreviated">
    <xsl:param name="maxLength" />
  
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label" />
    </xsl:variable>
 
    <xsl:call-template name="abbreviate">
      <xsl:with-param name="label">
        <xsl:apply-templates select="." mode="label" />
      </xsl:with-param>
      <xsl:with-param name="maxLength" select="$maxLength" />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:variable name="abbreviationsPropertiesPrefix">UBO.ClassificationOutput.Abbreviation.</xsl:variable>
  <xsl:variable name="abbreviations" select="document(concat('property:',$abbreviationsPropertiesPrefix,'*'))/properties" />
  
  <xsl:template name="abbreviate">
    <xsl:param name="label" />
    <xsl:param name="maxLength" />

    <xsl:for-each select="str:tokenize($label,' ')">
      <xsl:variable name="maxLengthGiven" select="string-length($maxLength) &gt; 0" />
      
      <xsl:variable name="abbreviationKeyName" select="concat($abbreviationsPropertiesPrefix,.)" />
      <xsl:variable name="abbreviation" select="$abbreviations/entry[@key=$abbreviationKeyName]" />
      
      <xsl:choose>
      
        <xsl:when test="starts-with(.,'(') or contains(.,')')">
          <xsl:value-of select="." />
        </xsl:when>
        
        <xsl:when test="$maxLengthGiven and (position() = ($UBO.ClassificationOutput.MaxWords + 1)) and (position() != last())">
          <xsl:value-of select="$dots" />
        </xsl:when>

        <xsl:when test="$maxLengthGiven and (position() &gt; $UBO.ClassificationOutput.MaxWords) and (position() != last())" />

        <xsl:when test="$maxLengthGiven and (string-length($abbreviation) &gt; 0)">
          <xsl:value-of select="$abbreviation" />
        </xsl:when>
        
        <xsl:when test="position() &lt; $UBO.ClassificationOutput.MaxWords">
          <xsl:value-of select="." />
        </xsl:when>

        <xsl:when test="$maxLengthGiven and (string-length(.) &gt; $maxLength)">
          <xsl:value-of select="substring(.,0,$maxLength)" />
          <xsl:value-of select="$dot" />
        </xsl:when>
        
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
        
      </xsl:choose>
      
      <xsl:if test="position() != last()">
        <xsl:text> </xsl:text>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>