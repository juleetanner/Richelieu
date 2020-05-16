<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:date="http://exslt.org/dates-and-times"
   xmlns:parse="http://cdlib.org/xtf/parse"
   xmlns:xtf="http://cdlib.org/xtf"
   xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
   extension-element-prefixes="date FileUtils"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0"
   exclude-result-prefixes="#all">
   
   <!--
      Copyright (c) 2008, Regents of the University of California
      All rights reserved.
      
      Redistribution and use in source and binary forms, with or without 
      modification, are permitted provided that the following conditions are 
      met:
      
      - Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
      - Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
      - Neither the name of the University of California nor the names of its
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.
      
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
      AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
      IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
      ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
      LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
      CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
      SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
      INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
      CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
      ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
      POSSIBILITY OF SUCH DAMAGE.
   -->
   
   <!-- ====================================================================== -->
   <!-- Import Common Templates and Functions                                  -->
   <!-- ====================================================================== -->
   
   <xsl:import href="../common/preFilterCommon.xsl"/>
   
   <!-- ====================================================================== -->
   <!-- Output parameters                                                      -->
   <!-- ====================================================================== -->
   
   <xsl:output method="xml" 
      indent="yes" 
      encoding="UTF-8"/>
   
   <!-- ====================================================================== -->
   <!-- Default: identity transformation                                       -->
   <!-- ====================================================================== -->
   
   <!-- altered 2020-05-06 for better whitespace on output —Syd -->
  <xsl:template match="node()">
    <xsl:if test="not(ancestor::*)">
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
   <!-- ====================================================================== -->
   <!-- Root Template                                                          -->
   <!-- ====================================================================== -->
   
   <xsl:template match="/*">
     <!-- modified for debugging 2020-05-06: put output into /tmp/, too —Syd -->
     <xsl:variable name="copy-for-indexer" as="element()">
       <xsl:copy>
         <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
         <xsl:copy-of select="@*"/>
         <xsl:call-template name="get-meta"/>
         <xsl:apply-templates/>
       </xsl:copy>
     </xsl:variable>
     <xsl:variable name="fn" select="tokenize(document-uri(/),'/')[last()]"/>
     <xsl:result-document href="/tmp/{$fn}">
       <xsl:sequence select="$copy-for-indexer"/>
     </xsl:result-document>
     <xsl:sequence select="$copy-for-indexer"/>
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- TEI Indexing                                                           -->
   <!-- ====================================================================== -->
   
   <!-- Ignored Elements. -->
   <xsl:template match="*:teiHeader">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="xtf:index" select="'no'"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   
   <!-- sectionType Indexing and Element Boosting -->
   <xsl:template match="*:head[parent::*[matches(local-name(),'^div')]]">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="xtf:sectionType" select="concat('head ', @type)"/>
         <xsl:attribute name="xtf:wordBoost" select="2.0"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="*:bibl">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="xtf:sectionType" select="'citation'"/>
         <xsl:attribute name="xtf:wordBoost" select="2.0"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="*:titlePart[ancestor::*:titlePage]">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="xtf:wordBoost" select="100.0"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   
   <!-- ====================================================================== -->
   <!-- Metadata Indexing                                                      -->
   <!-- ====================================================================== -->
   
   <xsl:template name="get-meta">
      <!-- Access Dublin Core Record (if present) -->
      <xsl:variable name="dcMeta">
         <xsl:call-template name="get-dc-meta"/>
      </xsl:variable>
      
      <!-- If no Dublin Core present, then extract meta-data from the TEI -->
      <xsl:variable name="meta">
         <xsl:choose>
            <xsl:when test="$dcMeta/*">
               <xsl:copy-of select="$dcMeta"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:call-template name="get-tei-title"/>
               <xsl:call-template name="get-tei-creator"/>
               <xsl:call-template name="get-tei-subject"/>
               <xsl:call-template name="get-tei-description"/>
               <xsl:call-template name="get-tei-publisher"/>
               <xsl:call-template name="get-tei-contributor"/>
               <xsl:call-template name="get-tei-date"/>
               <xsl:call-template name="get-tei-type"/>
               <xsl:call-template name="get-tei-format"/>
               <xsl:call-template name="get-tei-identifier"/>
               <xsl:call-template name="get-tei-source"/>
               <xsl:call-template name="get-tei-language"/>
               <xsl:call-template name="get-tei-relation"/>
               <xsl:call-template name="get-tei-coverage"/>
               <xsl:call-template name="get-tei-rights"/>
              <xsl:call-template name="get-tei-corresp-to-and-from"/>
               <!-- special values for OAI -->
               <xsl:call-template name="oai-datestamp"/>
               <xsl:call-template name="oai-set"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <!-- Add doc kind and sort fields to the data, and output the result. -->
      <xsl:call-template name="add-fields">
         <xsl:with-param name="display" select="'dynaxml'"/>
         <xsl:with-param name="meta" select="$meta"/>
      </xsl:call-template>    
   </xsl:template>
   
   <!-- title --> 
   <xsl:template name="get-tei-title">
      <xsl:choose>
        <!-- next <when> added 2020-05-06 —Syd -->
        <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[not(@type eq 'sub')]">
          <title xtf:meta="true">
            <xsl:value-of select="string(/TEI/teiHeader/fileDesc/titleStmt/title[not(@type eq 'sub')][1])"/>
          </title>
        </xsl:when>
        <xsl:when test="//*:fileDesc/*:titleStmt/*:title">
            <title xtf:meta="true">
               <xsl:value-of select="string(//*:fileDesc/*:titleStmt/*:title[1])"/>
            </title>
         </xsl:when>
         <xsl:when test="//*:titlePage/*:titlePart[@type='main']">
            <title xtf:meta="true">
               <xsl:value-of select="string(//*:titlePage/*:titlePart[@type='main'])"/>
               <xsl:if test="//*:titlePage/*:titlePart[@type='subtitle']">
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="string(//*:titlePage/*:titlePart[@type='subtitle'][1])"/>
               </xsl:if>
            </title>
         </xsl:when>
         <xsl:otherwise>
            <title xtf:meta="true">
               <xsl:value-of select="'unknown'"/>
            </title>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- creator --> 
   <xsl:template name="get-tei-creator">
      <xsl:choose>
        <!-- next <when> added 2020-05-06 —Syd -->
        <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author">
          <creator xtf:meta="true">
            <xsl:value-of select="string(/TEI/teiHeader/fileDesc/sourceDesc/bibl/author[1])"/>
          </creator>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader//correspAction[@type='sent']/persName">
          <creator xtf:meta="true">
            <xsl:value-of select="string(/TEI/teiHeader//correspAction[@type='sent']/persName[1])"/>
          </creator>
        </xsl:when>
        <xsl:when test="//*:fileDesc/*:titleStmt/*:author">
            <creator xtf:meta="true">
               <xsl:value-of select="string(//*:fileDesc/*:titleStmt/*:author[1])"/>
            </creator>
         </xsl:when>
         <xsl:when test="//*:titlePage/*:docAuthor">
            <creator xtf:meta="true">
               <xsl:value-of select="string(//*:titlePage/*:docAuthor[1])"/>
            </creator>
         </xsl:when>
         <xsl:otherwise>
            <creator xtf:meta="true">
               <xsl:value-of select="'unknown'"/>
            </creator>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- subject --> 
   <xsl:template name="get-tei-subject">
      <xsl:choose>
        <!-- Modified to allow <term> directly in <keywords> 2020-05-06 —Syd -->
         <xsl:when test="//*:keywords/*:list/*:item|//keywords/term">
            <xsl:for-each select="//*:keywords/*:list/*:item|//keywords/term">
               <subject xtf:meta="true">
                  <xsl:value-of select="."/>
               </subject>
            </xsl:for-each>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   
  <!-- description: modified 2020-05-16 to process correspDesc/note —Syd --> 
  <!-- Note: intended to cover JT's Richelieu data, not generic TEI -->
  <xsl:template name="get-tei-description">
    <!--
       Previous version tried to generate a description from the
       <correspAction> elements, perhaps to use instead of <title>,
       but I abandoned that idea when JT requested a particular
       <note> be used as the "Summary" field.
     -->
    <xsl:for-each select="/TEI/teiHeader//correspDesc[note[not(@resp)]]">
      <xsl:if test="note[not(@resp)][2]">
        <xsl:message select="concat(
          '&#x0A;Warning: there are 2+ note elements (without @resp) in correspDesc of ',
          ancestor::TEI/@xml:id,
          ', so I am just taking the 1st, thus probably getting this Summary wrong.'
          )"/>
      </xsl:if>
      <description xtf:meta="true">
        <xsl:sequence select="normalize-space( note[not(@resp)][1] )"/>
      </description>
    </xsl:for-each>
  </xsl:template>
  
  <!-- publisher -->
   <xsl:template name="get-tei-publisher">
      <xsl:choose>
         <xsl:when test="//*:fileDesc/*:publicationStmt/*:publisher">
            <publisher xtf:meta="true">
               <xsl:value-of select="string(//*:fileDesc/*:publicationStmt/*:publisher[1])"/>
            </publisher>
         </xsl:when>
         <xsl:when test="//*:text/*:front/*:titlePage//*:publisher">
            <publisher xtf:meta="true">
               <xsl:value-of select="string(//*:text/*:front/*:titlePage//*:publisher[1])"/>
            </publisher>
         </xsl:when>
         <xsl:otherwise>
            <publisher xtf:meta="true">
               <xsl:value-of select="'unknown'"/>
            </publisher>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- contributor -->
   <xsl:template name="get-tei-contributor">
      <xsl:choose>
         <xsl:when test="//*:fileDesc/*:respStmt/*:name">
            <contributor xtf:meta="true">
               <xsl:value-of select="string(//*:fileDesc/*:respStmt/*:name[1])"/>
            </contributor>
         </xsl:when>
         <xsl:otherwise>
            <contributor xtf:meta="true">
               <xsl:value-of select="'unknown'"/>
            </contributor>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- date --> 
   <xsl:template name="get-tei-date">
     <!-- modified 2020-05-06 to get the correct <date> only for JTR —Syd -->
     <!-- modified 2020-05-07 to use (only) @when —Syd -->
     <date xtf:meta="true">
       <xsl:value-of select="(
         /TEI/teiHeader/profileDesc/correspDesc/correspAction[@type eq 'sent']/date/@when,
         /TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when,
         'unknown')[1]"/>
     </date>
   </xsl:template>
   
   <!-- type -->
   <xsl:template name="get-tei-type">
      <type xtf:meta="true">tei</type>
   </xsl:template>
   
   <!-- format -->
   <xsl:template name="get-tei-format">
      <format xtf:meta="true">xml</format>
   </xsl:template>
   
   <!-- identifier --> 
   <xsl:template name="get-tei-identifier">
     <!-- Modified 2020-05-06 to return what JTR uses —Syd -->
     <xsl:value-of select="/TEI/@xml:id"/>
   </xsl:template>
  
   <!-- source -->
   <xsl:template name="get-tei-source">
     <!-- Modified 2020-05-06 to return entire <sourceDesc> —Syd -->
     <xsl:value-of select="string(/TEI/teiHeader/fileDesc/sourceDesc[1])"/>
   </xsl:template>
   
   <!-- language -->
   <xsl:template name="get-tei-language">
      <xsl:choose>
         <xsl:when test="//*:profileDesc/*:langUsage/*:language">
            <language xtf:meta="true">
               <xsl:value-of select="string((//*:profileDesc/*:langUsage/*:language)[1])"/>
            </language>
         </xsl:when>
         <xsl:otherwise>
            <language xtf:meta="true">
               <xsl:value-of select="'english'"/>
            </language>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- relation -->
   <xsl:template name="get-tei-relation">
      <xsl:choose>
         <xsl:when test="//*:fileDesc/*:seriesStmt/*:title">
            <relation xtf:meta="true">
               <xsl:value-of select="string(//*:fileDesc/*:seriesStmt/*:title)"/>
            </relation>
         </xsl:when>
         <xsl:otherwise>
            <relation xtf:meta="true">
               <xsl:value-of select="'unknown'"/>
            </relation>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- coverage -->
   <xsl:template name="get-tei-coverage">
      <coverage xtf:meta="true">
         <xsl:value-of select="'unknown'"/>
      </coverage>
   </xsl:template>
   
   <!-- rights -->
   <xsl:template name="get-tei-rights">
      <rights xtf:meta="true">
         <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/publicationStmt/availability)"/>
      </rights>
   </xsl:template>
  
  <!-- correspFrom and correspTo added 2020-05-07 —Syd -->  
   <xsl:template name="get-tei-corresp-to-and-from">
     <xsl:for-each select="
       /TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = ('sent','received')]
       ">
       <xsl:variable name="gi"
         select="concat('corresp', if (@type eq 'sent') then 'From' else 'To')"/>
       <xsl:element name="{$gi}">
         <xsl:attribute name="xtf:meta" select="'true'"/>
         <xsl:for-each select="persName|rs[@type eq 'person']">
           <xsl:choose>
             <xsl:when test="normalize-space(.) ne ''">
               <xsl:message select="concat('debug: content of ', name(.),', for ', $gi )"/>
               <xsl:value-of select="normalize-space( . )"/>
             </xsl:when>
             <xsl:when test="@ref">
               <xsl:variable name="ref" select="normalize-space(@ref)"/>
               <xsl:variable name="reffersto"
                 select="/TEI/standOff/listPerson/person[ @xml:id eq substring-after( $ref,'#') ]"/>
               <xsl:value-of select="$reffersto/persName[ @type eq 'presentation']/normalize-space()"/>
               <xsl:message select="concat(
                 'debug: ref=',@ref,
                 ' reffersto=',name($reffersto),'#',
                 count($reffersto/preceding-sibling::person),
                 ' name=',normalize-space($reffersto/persName[ @type eq 'presentation']),
                 ' for ', name(.),', for ', $gi)"/>
             </xsl:when>
           </xsl:choose>
           <xsl:choose>
             <xsl:when test="count( ../persName ) eq 2  and  following-sibling::persName">
               <xsl:text> and </xsl:text>
             </xsl:when>
             <xsl:when test="following-sibling::persName[2]">
               <xsl:text>, </xsl:text>
             </xsl:when>
             <xsl:when test="following-sibling::persName">
               <xsl:text>, and </xsl:text>
             </xsl:when>
           </xsl:choose>
         </xsl:for-each>
         <xsl:if test="not(persName|rs[@type eq 'person'])">
           <xsl:message select="'debug: unk'"/>
           <xsl:text>unknown</xsl:text>
         </xsl:if>
       </xsl:element>
     </xsl:for-each>
   </xsl:template>
   
   <!-- OAI dateStamp -->
   <xsl:template name="oai-datestamp" xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils">
      <xsl:variable name="filePath" select="saxon:system-id()" xmlns:saxon="http://saxon.sf.net/"/>
      <dateStamp xtf:meta="true" xtf:tokenize="no">
         <xsl:value-of select="FileUtils:lastModified($filePath, 'yyyy-MM-dd')"/>
      </dateStamp>
   </xsl:template>
   
   <!-- OAI sets -->
   <xsl:template name="oai-set">
      <xsl:for-each select="//*:keywords/*:list/*:item">
         <set xtf:meta="true">
            <xsl:value-of select="."/>
         </set>
      </xsl:for-each>
      <set xtf:meta="true">
         <xsl:value-of select="'public'"/>
      </set>
   </xsl:template>
   
</xsl:stylesheet>
