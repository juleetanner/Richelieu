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

  <xsl:param name="outDir" select="'xtf/data/'"/>
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
        <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
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
      <xsl:apply-templates select="*" mode="merge"/>
      <xsl:apply-templates select="$corpusHeader/*[ not( name(.) = current()/*/name() ) ]"
        mode="merge"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="teiHeader/*" mode="merge">
    <xsl:variable name="me" select="name(.)"/>
    <xsl:copy>
      <xsl:comment>from teiHeader/* of <xsl:value-of
        select="if (ancestor::TEI) then 'TEI' else 'teiCorpus'"/></xsl:comment>
      <xsl:apply-templates select="$corpusHeader/*[name(.) eq $me]/@*" mode="#current"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*" mode="#current"/>
      <xsl:apply-templates select="
        $corpusHeader
        /*[ name(.) eq $me ]
        /*[
            not(
              name(.)
              =
              current()/*/name(.)
              )
           ]"
        mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="teiHeader/*/*" mode="merge">
    <xsl:variable name="me" select="name(.)"/>
    <xsl:variable name="parent" select="name(..)"/>
    <xsl:copy>
      <xsl:comment>from teiHeader/*/* of <xsl:value-of
        select="if (ancestor::TEI) then 'TEI' else 'teiCorpus'"/></xsl:comment>
      <xsl:apply-templates select="$corpusHeader/*[name(..) eq $parent]/*[name(.) eq $me]/@*"
      mode="#current"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*|$corpusHeader/*[name(..) eq $parent]/*[name(.) eq $me]/*" 
        mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text">
    <!--
      This entire template exists to insert a fake <titlePage> if there isn't one already
    -->
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="front">
          <xsl:apply-templates select="front"/>
        </xsl:when>
        <xsl:otherwise>
          <front>
            <xsl:comment> This &lt;front> inserted automatically to ensure there is a &lt;titlePage> </xsl:comment>
            <titlePage>
              <titlePart type="sub">
                brought to you by XTF
              </titlePart>
            </titlePage>
          </front>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="body|back"/>
    </xsl:copy>
  </xsl:template>


  <!--
    If you, dear reader, do not find more intelligent licensing information either in
    this file (which means this should have been deleted) or in the parent repository,
    presume this code is available under the MIT license. That is, you should feel free
    to use, copy, modify, whatever, but be sure to include copyright notice, and please
    give me credit for whatever parts you use or steal or whatever. — Syd
  -->

</xsl:stylesheet>
