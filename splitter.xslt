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
  <xsl:variable name="apos" select='"&apos;"'/>
  
  <!-- currently unsed keys: -->
  <xsl:key name="persName-by-ref" match="body//persName" use="@ref"/>
  <xsl:key name="placeName-by-ref" match="body//placeName" use="@ref"/>
  
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
              <titlePart type="main">
                <xsl:apply-templates select="../teiHeader/fileDesc/titleStmt/title"/>
              </titlePart>
            </titlePage>
            <!--
              Note: generated <div> in <front> (which are <div1> in original XTF) must have
              a @type to match that in xtf/style/dynaXML/docFormatter/tei/titlepage.xsl,
              and must have an @xml:id, whose value is irrelevant, I think. —Syd, 2020-05-17
            -->
            <div type="copyright" xml:id="L{translate( ../@xml:id,'[letr]','')}avail">
              <xsl:value-of select="normalize-space( ../teiHeader/fileDesc//availability)"/>
            </div>
          </front>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="body|back"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Note: following two templates have no concern of overwriting an existing
    (persName|placeName)/@n, because there are none in the input.
  -->
  <!-- put an n=first on the first of any given <persName> -->
  <xsl:template match="body//persName">
    <xsl:variable name="myRef" select="normalize-space(@ref)"/>
    <xsl:copy>
      <xsl:if test="not(preceding::persName[ancestor::body][normalize-space(@ref) eq $myRef])">
        <xsl:attribute name="n" select="'first'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
     
  <!-- put an n=first on the first of any given <placeName> -->
  <xsl:template match="body//placeName">
    <xsl:variable name="myRef" select="normalize-space(@ref)"/>
    <xsl:copy>
      <xsl:if test="not(preceding::placeName[ancestor::body][normalize-space(@ref) eq $myRef])">
        <xsl:attribute name="n" select="'first'"/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!--
    Convert <note> (which is encoded where the note is anchored) to a sequence
    of <ref><note>, as XTF expects the <ref>, and does not care where the <note>
    is.
  -->
  <xsl:template match="body//note[ not( @type eq 'temp') ]">
    <xsl:variable name="id" select="generate-id()"/>
    <xsl:variable name="refNum">
      <xsl:number level="any" from="body" format="[1]"/>
    </xsl:variable>
    <ref type="fnoteref" target="#{$id}">
      <xsl:sequence select="$refNum"/>
    </ref>
    <note type="footnote" xml:id="{$id}" n="{$refNum}">
      <xsl:apply-templates select="@* except ( @type, @xml:id, @n )"/>
      <xsl:apply-templates select="node()"/>
    </note>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:value-of select="
      replace( ., $apos,'’')
      => replace('\s&quot;', ' “')
      => replace('&quot;', '”')
      => replace('([0-9])-([0-9])','$1–$2')
      "/>
  </xsl:template>
  
  <!--
    If you, dear reader, do not find more intelligent licensing information either in
    this file (which means this should have been deleted) or in the parent repository,
    presume this code is available under the MIT license. That is, you should feel free
    to use, copy, modify, whatever, but be sure to include copyright notice, and please
    give me credit for whatever parts you use or steal or whatever. — Syd
  -->

</xsl:stylesheet>
