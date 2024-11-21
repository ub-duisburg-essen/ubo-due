<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:str="http://exslt.org/strings">

  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="indentStyle" select="'spaces'" />

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
              <xsl:with-param name="maxLength" select="10" />
            </xsl:apply-templates>
            <xsl:text>&#160;&#187;&#160;</xsl:text>
          </xsl:when>
          
          <xsl:when test="$indentStyle='ancestors'">
            <xsl:value-of select="$indent" /><br/>
            <xsl:apply-templates select="." mode="label">
              <xsl:with-param name="maxLength" select="10" />
            </xsl:apply-templates>
            <xsl:text>&#160;&#187;&#160;</xsl:text>
          </xsl:when>
          
          <xsl:otherwise> <!-- default: spaces -->
            <xsl:value-of select="$indent" />
            <xsl:text>&#160;&#160;</xsl:text>
          </xsl:otherwise>
          
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:variable name="defaultMaxLength" select="999" />
  
  <xsl:template match="category" mode="label">
    <xsl:param name="maxLength" select="$defaultMaxLength" />
  
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
      <xsl:choose>
      
        <xsl:when test="contains(.,'(')">
          <xsl:value-of select="." />
        </xsl:when>
        
        <xsl:when test="($maxLength &lt; $defaultMaxLength) and (position() &gt; 3) and (position() != last())" />
        
        <xsl:when test="($maxLength &lt; $defaultMaxLength) and (. = 'Fakultät')">Fak.</xsl:when>
        <xsl:when test="($maxLength &lt; $defaultMaxLength) and (. = 'Institut')">Inst.</xsl:when>
        <xsl:when test="($maxLength &lt; $defaultMaxLength) and (. = 'Klinik')">Kl.</xsl:when>
        <xsl:when test="($maxLength &lt; $defaultMaxLength) and (. = 'für')">f.</xsl:when>
        <xsl:when test="($maxLength &lt; $defaultMaxLength) and (. = 'und')">u.</xsl:when>
        
        <xsl:when test="string-length(.) &gt; ($maxLength + 2)">
          <xsl:value-of select="substring(.,0,$maxLength)" />
          <xsl:text>&#8230;</xsl:text>
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