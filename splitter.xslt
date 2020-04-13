<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  version="3.0">

  <!--
    splitter.xslt
    © 2020 Syd Bauman and Julee Tanner, few rights reserved (see end-of-file for details)
    Read in Julee Tanner’s TEI Corpus of the correspondence of Cardinal Richelieu, and
    write out each <TEI> document as a separate file, complete with a combined header and
    a copy of the <standOff>.
  -->
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <!-- By default the output path is currently set to work on Syd’s desktop. -->
  <xsl:param name="outDir" select="'/var/lib/tomcat8/webapps/JTR/data'"/>
  <!-- Remove trailing slash, if any: -->
  <xsl:variable name="outPath" select="normalize-space($outDir) => replace('/$','')"/>

  <xsl:variable name="inputFileName" select="tokenize( document-uri(/),'/')[last()]"/>
  <xsl:variable name="corpusHeader" select="/teiCorpus/teiHeader" as="element(teiHeader)"/>
  
  <xsl:mode name="merge" on-no-match="shallow-copy"/>
  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="/teiCorpus">
    <xsl:apply-templates select="TEI"/>
  </xsl:template>

  <xsl:template match="TEI">
    <xsl:variable name="outputFileName"
      select="replace( $inputFileName,'\.xml$', '_'||@xml:id||'.xml')"/>
    <xsl:result-document href="{$outPath}/{$outputFileName}">
      <xsl:copy>
        <xsl:apply-templates select="/teiCorpus/@*"/>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="teiHeader" mode="merge"/>
        <xsl:apply-templates select="/teiCorpus/standOff"/>
        <xsl:apply-templates select="text"/>
      </xsl:copy>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="teiHeader" mode="merge">
    <xsl:copy>
      <xsl:apply-templates select="$corpusHeader/@*"/>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|$corpusHeader/*" mode="merge"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="teiHeader/*" mode="merge">
    <xsl:variable name="me" select="name(.)"/>
    <xsl:copy>
      <xsl:apply-templates select="$corpusHeader/*[name(.) eq $me]/@*" mode="#current"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*|$corpusHeader/*[name(.) eq $me]/*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="teiHeader/*/*" mode="merge">
    <xsl:variable name="me" select="name(.)"/>
    <xsl:variable name="parent" select="name(..)"/>
    <xsl:copy>
      <xsl:apply-templates select="$corpusHeader/*[name(..) eq $parent]/*[name(.) eq $me]/@*"
      mode="#current"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*|$corpusHeader/*[name(..) eq $parent]/*[name(.) eq $me]/*" 
        mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:mode name="merge" on-no-match="shallow-copy"/>

</xsl:stylesheet>