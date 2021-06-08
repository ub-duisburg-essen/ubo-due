<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="xsl xalan i18n mcrxsl encoder exslt">

  <xsl:output method="html" encoding="UTF-8" media-type="text/html" indent="yes" xalan:indent-amount="2" />

  <!-- ==================== LANGUAGE PARAMS ==================== -->

  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="UBO.Login.Path" />

  <xsl:variable name="AvailableLanguages" select="'de,en'" />

  <!-- ==================== WEBJARS VERSIONS (see pom.xml) ==================== -->

  <xsl:variable name="jquery.version" select="'3.3.1'" />
  <xsl:variable name="jquery-ui.version" select="'1.12.1'" />
  <xsl:variable name="chosen.version" select="'1.8.7'" />
  <xsl:variable name="bootstrap.version" select="'4.4.1'" />
  <xsl:variable name="font-awesome.version" select="'5.13.0'" />

  <!-- ==================== INCLUDES ==================== -->

  <xsl:include href="coreFunctions.xsl" />
  <xsl:include href="html-layout-backend.xsl" />

  <!-- ==================== HTML ==================== -->

  <xsl:template match="/html">
    <xsl:call-template name="doctype" />

    <html lang="{$CurrentLang}">
      <xsl:apply-templates select="head" />

      <body>
        <header>
          <xsl:call-template name="head-bar" />
          <xsl:call-template name="site-header" />
          <xsl:call-template name="ubo-main-nav" />
        </header>

        <xsl:call-template name="title.breadcrumb.container" />
        <xsl:call-template name="layout.body" />

        <xsl:call-template name="footer" />
        </body>

      </html>
  </xsl:template>

  <xsl:template name="doctype">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>

    </xsl:text>
  </xsl:template>

  <!-- ==================== HTML HEAD ==================== -->

  <xsl:template match="head">
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta charset="utf-8" />

      <link rel="icon" href="{$WebApplicationBaseURL}favicon.ico" type="image/x-icon" />

      <link rel="stylesheet" href="{$WebApplicationBaseURL}webjars/font-awesome/{$font-awesome.version}/css/all.css" />
      <link rel="stylesheet" href="{$WebApplicationBaseURL}rsc/sass/scss/bootstrap-ubo.css"  />
      <link rel="stylesheet" href="{$WebApplicationBaseURL}webjars/chosen-js/{$chosen.version}/chosen.min.css" />
      <link rel="stylesheet" href="{$WebApplicationBaseURL}webjars/jquery-ui/{$jquery-ui.version}/jquery-ui.css" />
      <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Droid+Sans|Droid+Sans+Mono" />

      <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/jquery/{$jquery.version}/jquery.min.js"></script>
      <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/bootstrap/{$bootstrap.version}/js/bootstrap.bundle.min.js"></script>
      <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/chosen-js/{$chosen.version}/chosen.jquery.min.js"></script>
      <script type="text/javascript" src="{$WebApplicationBaseURL}webjars/jquery-ui/{$jquery-ui.version}/jquery-ui.js"></script>

      <script type="text/javascript">var webApplicationBaseURL = '<xsl:value-of select="$WebApplicationBaseURL" />';</script>
      <script type="text/javascript">var currentLang = '<xsl:value-of select="$CurrentLang" />';</script>

      <xsl:copy-of select="node()" />
    </head>
  </xsl:template>

  <!-- ==================== HEAD BAR ==================== -->

  <xsl:template name="head-bar">
    <div class="head-bar">
      <div class="container" >
        <div class="mir-prop-nav">
          <nav>
            <ul class="navbar-nav flex-row flex-wrap align-items-center">
              <xsl:for-each select="$navigation.tree/item[@menu='header']/item">
                <li>
                  <a href="{@href}">
                    <i class="fas fa-fw fa-{@icon}" />
                    <span class="icon-label">
                      <xsl:call-template name="output.label.for.lang" />
                    </span>
                  </a>
                </li>
              </xsl:for-each>
              <xsl:call-template name="language-switcher" />
            </ul>
          </nav>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ==================== LANGUAGE SWITCHER ==================== -->

  <xsl:template name="language-switcher">
    <xsl:variable name="availableLanguages">
      <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
        <xsl:with-param name="string" select="$AvailableLanguages" />
        <xsl:with-param name="delimiter" select="','" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="langToken" select="exslt:node-set($availableLanguages)/token" />
    <xsl:if test="count($langToken) &gt; 1">
      <xsl:variable name="curLang" select="document(concat('language:',$CurrentLang))" />
<!--       <language termCode="deu" biblCode="ger" xmlCode="de"> -->
<!--         <label xml:lang="de">Deutsch</label> -->
<!--         <label xml:lang="en">German</label> -->
<!--       </language> -->
      <li class="nav-item dropdown ml-auto mir-lang">
        <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" title="{i18n:translate('ude.layout.changeLanguage')}">
          <i class="flag flag-{$curLang/language/@xmlCode}" />
          <span class="current-language">
            <xsl:value-of select="translate($curLang/language/@xmlCode,'den','DEN')" />
          </span>
          <span class="caret" />
        </a>
        <ul class="dropdown-menu language-menu" role="menu">
          <xsl:for-each select="$langToken">
            <xsl:variable name="lang"><xsl:value-of select="mcrxsl:trim(.)" /></xsl:variable>
            <xsl:if test="$lang!='' and $CurrentLang!=$lang">
              <xsl:variable name="langDef" select="document(concat('language:',$lang))" />
              <li>
                <xsl:variable name="langURL">
                  <xsl:call-template name="layout.languageLink">
                    <xsl:with-param name="lang" select="$langDef/language/@xmlCode" />
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="langTitle">
                  <xsl:apply-templates select="$langDef/language" mode="layout.langTitle" />
                </xsl:variable>
                <a href="{$langURL}" class="dropdown-item" title="{$langTitle}">
                  <i class="flag flag-{$langDef/language/@xmlCode}" />
                  <xsl:value-of select="$langTitle" />
                </a>
              </li>
            </xsl:if>
          </xsl:for-each>
        </ul>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="language" mode="layout.langTitle">
    <xsl:variable name="code" select="@xmlCode" />
    <xsl:choose>
      <xsl:when test="label[lang($code)]">
        <xsl:value-of select="label[lang($code)]" />
      </xsl:when>
      <xsl:when test="label[lang($CurrentLang)]">
        <xsl:value-of select="label[lang($CurrentLang)]" />
      </xsl:when>
      <xsl:when test="label[lang($DefaultLang)]">
        <xsl:value-of select="label[lang($DefaultLang)]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@xmlCode" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="layout.languageLink">
    <xsl:param name="lang" />
    <xsl:variable name="langURL">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'lang'" />
        <xsl:with-param name="value" select="$lang" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="UrlAddSession">
      <xsl:with-param name="url" select="$langURL" />
    </xsl:call-template>
  </xsl:template>

  <!-- ==================== SITE HEADER ==================== -->

  <xsl:template name="site-header">
    <div class="site-header">
      <div class="container">
        <div class="row">
          <div class="col-12 col-sm-6 col-md-auto">
            <a href="https://www.uni-due.de/de/index.php" id="udeLogo" class="containsimage">
              <span>
                <xsl:value-of select="i18n:translate('ude.university')" />
              </span>
              <img src="{$WebApplicationBaseURL}images/UDE-logo-claim.svg" alt="Logo {i18n:translate('ude.university')}" width="1052" height="414" />
            </a>
          </div>
          <div class="col-12 col-sm-6 col-md-auto">
            <div id="orgaunitTitle">
              <a href="{$WebApplicationBaseURL}">
                <h1>
                  <xsl:value-of select="i18n:translate('ude.ubo')" />
                </h1>
                <h2>
                  <xsl:value-of select="i18n:translate('ude.ubo.subTitle')" />
                </h2>
              </a>
            </div>
          </div>
          <div class="col-12 col-md">
            <form action="{$WebApplicationBaseURL}servlets/solr/select" class="searchfield_box form-inline my-2 my-lg-0" role="search">
              <div class="input-group mb-3">
                <input id="searchInput" class="form-control mr-sm-2 search-query" type="search" name="qq" placeholder="{i18n:translate('ude.layout.searchPublications')}" aria-label="{i18n:translate('ude.layout.searchPublications')}" />
                <input type="hidden" name="sort" value="year desc" />
                <input type="hidden" name="fl" value="*" />
                <input type="hidden" name="rows" value="10" />

                <!-- Standard users must only find confirmed publications, admins find all publications -->
                <input type="hidden" name="q">
                  <xsl:attribute name="value">
                    <xsl:choose>
                      <xsl:when xmlns:check="xalan://org.mycore.ubo.AccessControl" test="check:currentUserIsAdmin()">
                        <xsl:text>objectType:mods</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>status:confirmed</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> AND ${qq}</xsl:text>
                  </xsl:attribute>
                </input>

                <div class="input-group-append">
                  <button class="btn btn-primary" type="submit"><i class="fas fa-search" /></button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ==================== MAIN NAVIGATION MENU ==================== -->

  <xsl:template name="ubo-main-nav">
    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="mir-main-nav bg-primary">
      <div class="container">
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">

          <button class="navbar-toggler" type="button"
            data-toggle="collapse" data-target="#mir-main-nav-collapse-box"
            aria-controls="mir-main-nav-collapse-box" aria-expanded="false" aria-label="{i18n:translate('ude.layout.toggleNavigation')}">
            <span class="navbar-toggler-icon" />
          </button>

          <div id="mir-main-nav-collapse-box" class="collapse navbar-collapse mir-main-nav__entries">
            <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
              <xsl:call-template name="layout.mainnav" />
              <xsl:call-template name="menu.basket" />
            </ul>
            <ul class="navbar-nav">
              <xsl:call-template name="menu.login" />
            </ul>
          </div>
        </nav>

      </div>
    </div>
  </xsl:template>

  <!-- ==================== BASKET MENU ==================== -->

  <xsl:template name="menu.basket">
    <xsl:variable name="basket" select="document('basket:objects')/basket" />
      <xsl:variable name="entryCount" select="count($basket/entry)" />

    <li class="dropdown" id="basket-list-item">
      <a class="dropdown-toggle nav-link" data-toggle="dropdown" href="#">
        <xsl:attribute name="title">
          <xsl:choose>
            <xsl:when test="$entryCount = 0">
              <xsl:value-of select="i18n:translate('basket.numEntries.none')" />
            </xsl:when>
            <xsl:when test="$entryCount = 1">
              <xsl:value-of select="i18n:translate('basket.numEntries.one')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="i18n:translate('basket.numEntries.many',$entryCount)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <i class="fas fa-bookmark" />
        <sup>
          <xsl:value-of select="$entryCount" />
        </sup>
      </a>
      <ul class="dropdown-menu" role="menu">
        <li>
          <a  class="dropdown-item" href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basket/@type}&amp;action=show">
            <xsl:value-of select="i18n:translate('basket.show')" />
          </a>
        </li>
      </ul>
    </li>
  </xsl:template>

  <!-- ==================== LOGIN MENU ==================== -->

  <xsl:template name="menu.login">
    <xsl:choose>
      <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
        <li class="nav-item">
          <xsl:variable name="url" select="encoder:encode(string($RequestURL))" />
          <a id="loginURL" class="nav-link" href="{$WebApplicationBaseURL}{$UBO.Login.Path}?url={$url}">
            <xsl:value-of select="i18n:translate('component.userlogin.button.login')" />
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="nav-item dropdown">

          <a id="currentUser" class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
            <xsl:choose>
              <xsl:when test="contains($CurrentUser,'@')">
                <xsl:value-of select="substring-before($CurrentUser,'@')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$CurrentUser" />
              </xsl:otherwise>
            </xsl:choose>
            <span class="caret" />
          </a>

          <ul class="dropdown-menu dropdown-menu-right" role="menu">

            <xsl:if test="contains($CurrentUser,'@')">
              <xsl:apply-templates select="$navigation.tree/item[@menu='user']/item" mode="dropdown" />
            </xsl:if>
            <xsl:if xmlns:check="xalan://org.mycore.ubo.AccessControl" test="check:currentUserIsAdmin()">
              <xsl:apply-templates select="$navigation.tree/item[@menu='admin']/item" mode="dropdown" />
            </xsl:if>

            <li class="dropdown-divider" role="presentation" />
            <li>
              <a id="logoutURL" class="dropdown-item" href="{$ServletsBaseURL}logout?url=/index.xed">
                <xsl:value-of select="i18n:translate('component.userlogin.button.logout')" />
              </a>
            </li>
          </ul>

        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="item" mode="dropdown">
    <li>
      <a href="{$WebApplicationBaseURL}{@ref}" class="dropdown-item">
        <xsl:call-template name="output.label.for.lang" />
      </a>
    </li>
  </xsl:template>

  <!-- ==================== TITLE BREADCRUMB CONTAINER ==================== -->

  <xsl:template name="title.breadcrumb.container">
    <div id="pagetitlecontainer">
      <div class="container-background">
        <div class="container">
          <div class="pagetitle">
            <h1>
              <xsl:value-of select="head/title" disable-output-escaping="yes" />
            </h1>
            <xsl:call-template name="breadcrumbPath" />
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="breadcrumbPath">
    <nav class="rootline" aria-label="breadcrumb">
      <ol class="breadcrumb py-1" vocab="http://schema.org/" typeof="BreadcrumbList">
        <li class="breadcrumb-item" property="itemListElement" typeof="ListItem">
          <a href="https://www.uni-due.de/ub/" property="item" typeof="WebPage">
            <i class="fas fa-home mr-2" />
            <xsl:text>UB</xsl:text>
          </a>
        </li>
        <li class="breadcrumb-item" property="itemListElement" typeof="ListItem">
          <a href="{$WebApplicationBaseURL}" property="item" typeof="WebPage">
            <xsl:value-of select="i18n:translate('ude.ubo')" />
          </a>
        </li>
        <xsl:apply-templates mode="breadcrumb" select="$CurrentItem/ancestor-or-self::item[@label|label][ancestor-or-self::*=$navigation.tree[@role='main']]" />
        <xsl:for-each select="body/ul[@id='breadcrumb']/li">
          <li class="breadcrumb-item" property="itemListElement" typeof="ListItem">
            <xsl:copy-of select="node()" />
          </li>
        </xsl:for-each>
      </ol>
    </nav>
  </xsl:template>

  <xsl:template match="item" mode="breadcrumb">
    <li class="breadcrumb-item" property="itemListElement" typeof="ListItem">
      <xsl:call-template name="output.item.label" />
    </li>
  </xsl:template>

  <!-- ==================== MAIN CONTENT ==================== -->

  <xsl:template name="layout.body">
    <div class="bodywrapper pt-3">
      <div class="container d-flex flex-column flex-grow-1">
        <div class="row">
          <div class="col-lg">
            <xsl:call-template name="layout.inhalt" />
          </div>
          <xsl:if test="body/aside[@id='sidebar']">
            <div class="col-lg-3 pl-lg-0">
              <xsl:copy-of select="body/aside[@id='sidebar']" />
            </div>
          </xsl:if>
        </div>
        <div class="row">
          <div class="col">
            <hr class="mb-0"/>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="layout.inhalt">
    <section role="main" id="inhalt">
      <xsl:choose>
        <xsl:when test="$allowed.to.see.this.page = 'true'">
          <xsl:copy-of select="body/*[not(@id='sidebar')][not(@id='breadcrumb')]" />
        </xsl:when>
        <xsl:otherwise>
          <h3>
            <xsl:value-of select="i18n:translate('navigation.notAllowedToSeeThisPage')" />
          </h3>
        </xsl:otherwise>
      </xsl:choose>
    </section>
  </xsl:template>

  <!-- ==================== WHERE DOES THIS BELONG TO ? ==================== -->

  <!-- custom navigation for additional information -->

  <xsl:template name="layout.sub.navigation.information">
    <xsl:for-each select="$navigation.tree/item[@menu='information']">
      <a href="#" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        <i class="far fa-fw fa-user"></i>
        <span class="icon-label"><xsl:call-template name="output.label.for.lang"/></span>
      </a>
    </xsl:for-each>
    <ul class="dropdown-menu">
      <xsl:for-each select="$navigation.tree/item[@menu='information']/item">
        <li>
          <xsl:call-template name="output.item.label"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- If current user has ORCID and we are his trusted party, display ORCID icon to indicate that -->
  <xsl:param name="MCR.ORCID.LinkURL" />

  <xsl:template name="orcidUser">

    <xsl:variable name="orcidUser" select="orcidSession:getCurrentUser()" xmlns:orcidSession="xalan://org.mycore.orcid.user.MCRORCIDSession" />
    <xsl:variable name="userStatus" select="orcidUser:getStatus($orcidUser)" xmlns:orcidUser="xalan://org.mycore.orcid.user.MCRORCIDUser" />
    <xsl:variable name="trustedParty" select="userStatus:weAreTrustedParty($userStatus)" xmlns:userStatus="xalan://org.mycore.orcid.user.MCRUserStatus" />

    <xsl:if test="$trustedParty = 'true'">
      <xsl:variable name="orcid" select="orcidUser:getORCID($orcidUser)" xmlns:orcidUser="xalan://org.mycore.orcid.user.MCRORCIDUser" />
      <a href="{$MCR.ORCID.LinkURL}{$orcid}">
        <img alt="ORCID {$orcid}" src="{$WebApplicationBaseURL}images/orcid_icon.svg" class="orcid-icon" />
      </a>
    </xsl:if>
  </xsl:template>

  <!-- ==================== FOOTER ==================== -->

  <xsl:template name="footer">
    <footer>
      <div class="footer-menu">
        <div class="container">
          <div class="row">

            <div class="col" id="footerLogo">
              <a href="https://www.uni-due.de/de/index.php" class="containsimage">
                <img src="{$WebApplicationBaseURL}images/UDE-logo-claim-dark.svg" class="mb-5" alt="Logo {i18n:translate('ude.university')}" width="1052" height="414" />
              </a>
            </div>

            <div class="col col-md-auto justify-content-end">

              <nav id="navigationFooter" class="navbar">
                <ul>
                  <xsl:for-each select="$navigation.tree/item[@menu='footer']/item">
                    <li>
                      <a href="{@href}" class="footer-menu__entry">
                        <xsl:copy-of select="@href" />
                        <xsl:for-each select="@ref">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($WebApplicationBaseURL,.)" />
                          </xsl:attribute>
                        </xsl:for-each>
                        <i class="fas fa-fw fa-{@icon}" />
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="output.label.for.lang" />
                      </a>
                    </li>
                  </xsl:for-each>
                </ul>
              </nav>

              <div id="footerCopyright" class="navbar">
                <ul class="nav">
                  <li>
                    <xsl:value-of select="i18n:translate('ude.layout.copyright')" />
                  </li>
                  <li>
                    <a href="mailto:{i18n:translate('ude.contact.mail')}" class="footer-menu__entry">
                      <i class="fas fa-fw fa-envelope" />
                      <xsl:value-of select="i18n:translate('ude.contact.mail')" />
                    </a>
                  </li>
                </ul>
              </div>
            </div>

          </div>
        </div>
      </div>
    </footer>
  </xsl:template>

</xsl:stylesheet>
