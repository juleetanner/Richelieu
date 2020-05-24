<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc notBefore="1964-10-20" notAfter="2020-05-23">
      <xd:p><xd:b>Created on:</xd:b> May 23, 2020</xd:p>
      <xd:p><xd:b>Author:</xd:b> syd</xd:p>
      <xd:p>read in a corpus of letters, write out the average of all dates sent</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:variable name="born" select="'1585-09-09' cast as xs:date"/>
    <xsl:variable name="dates_sent" as="xs:date+">
      <xsl:sequence select="/*/*/teiHeader//correspAction[@type eq 'sent']//date/@when"/>
      <xsl:sequence select="/*/*/teiHeader//correspAction[@type eq 'sent']//date/@notBefore"/>
      <xsl:sequence select="/*/*/teiHeader//correspAction[@type eq 'sent']//date/@notAfter"/>
      <xsl:sequence select="/*/*/teiHeader//correspAction[@type eq 'sent']//date[not(@when|@notBefore|@notAfter)][normalize-space(.) ne '']"/>
    </xsl:variable>
    <xsl:variable name="age_when_sent" as="xs:duration+">
      <xsl:for-each select="$dates_sent">
        <xsl:sequence select=". - $born"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="avg" select="avg( $age_when_sent )" as="xs:duration"/>
    <xsl:value-of select="$avg + $born"/>
  </xsl:template>
  
</xsl:stylesheet>