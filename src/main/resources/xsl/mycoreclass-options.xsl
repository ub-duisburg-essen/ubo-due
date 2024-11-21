<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="xsl str"
>

  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="indentStyle" select="'spaces'" />
  
  <xsl:variable name="dot" select="'.'" />
  <xsl:variable name="dots" select="'&#8230;'" />
  <xsl:variable name="nbsp" select="'&#160;'" />
  <xsl:variable name="parentChildDelimiter" select="concat($nbsp,'&#187;',$nbsp)" />

  <xsl:variable name="maxWords" select="4" />
  <xsl:variable name="maxWordLength" select="10" />

  <xsl:template match="/mycoreclass">
    <includes>
      <xsl:apply-templates select="categories/category" />
    </includes>
  </xsl:template>
  
  <xsl:template match="category">
    <xsl:param name="indent" />
    
    <option value="{@ID}">
      <xsl:value-of select="$indent" />
      <xsl:apply-templates select="." mode="label" />
    </option>
    
    <xsl:apply-templates select="category">
      <xsl:with-param name="indent">
        <xsl:choose>
        
          <xsl:when test="$indentStyle='parent'">
            <xsl:apply-templates select="." mode="label">
              <xsl:with-param name="maxLength" select="$maxWordLength" />
            </xsl:apply-templates>
            <xsl:value-of select="$parentChildDelimiter" />
          </xsl:when>
          
          <xsl:when test="$indentStyle='ancestors'">
            <xsl:value-of select="$indent" /><br/>
            <xsl:apply-templates select="." mode="label">
              <xsl:with-param name="maxLength" select="$maxWordLength" />
            </xsl:apply-templates>
            <xsl:value-of select="$parentChildDelimiter" />
          </xsl:when>
          
          <xsl:otherwise> <!-- default: spaces -->
            <xsl:value-of select="$indent" />
            <xsl:value-of select="concat($nbsp,$nbsp)" />
          </xsl:otherwise>
          
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template match="category" mode="label">
    <xsl:param name="maxLength" />
  
    <xsl:variable name="label">
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
    </xsl:variable>
    
    <xsl:for-each select="str:tokenize($label,' ')">
      <xsl:variable name="maxLengthGiven" select="string-length($maxLength) &gt; 0" />
      <xsl:choose>
      
        <xsl:when test="starts-with(.,'(') or contains(.,')')">
          <xsl:value-of select="." />
        </xsl:when>
        
        <xsl:when test="$maxLengthGiven and (position() = ($maxWords + 1)) and (position() != last())">
          <xsl:value-of select="$dots" />
        </xsl:when>

        <xsl:when test="$maxLengthGiven and (position() &gt; $maxWords) and (position() != last())" />
        
        <xsl:when test="$maxLengthGiven and (. = 'Fakultät')"><b>Fak.</b></xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Faculty')">Fac.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Institut')">Inst.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Institute')">Inst.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Fachgebiet')">FG</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Klinik')">Kl.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Clinic')">Cl.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Zentrum')">Z.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'Center')">C.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'für')">f.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'for')">f.</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'und')">&amp;</xsl:when>
        <xsl:when test="$maxLengthGiven and (. = 'and')">&amp;</xsl:when>
        
        <xsl:when test="position() &lt; $maxWords">
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