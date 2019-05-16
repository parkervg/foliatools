<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
   xmlns:folia="http://ilk.uvt.nl/folia"
   xmlns:edate="http://exslt.org/dates-and-times"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns:xlink="https://www.w3.org/1999/xlink"
   exclude-result-prefixes="tei edate xlink" version="1.0"
   xmlns="http://ilk.uvt.nl/folia"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<!--
TEI2FoLiA Converter

Considering the enormous variety of TEI documents, this converter
only covers a subset and is not guaranteed to work!

Based on work by Jesse de Does (INT)
Heavily adapted by Maarten van Gompel (Radboud University)
-->

<xsl:output method="xml" indent="yes"/>
<!--
  <xsl:strip-space elements="*"/>
-->

<xsl:strip-space elements="l p interp meta interpGrp"/>
<xsl:param name="docid"><xsl:value-of select="//publicationStmt/idno/text()"/></xsl:param>

<!-- TEI elements that translate to FoLiA markup elements -->
<xsl:variable name="teimarkupelements">hi|pb|add|name|note|corr|supplied|add|del</xsl:variable>
<!-- TEI elements that translate to FoLiA structure elements -->
<xsl:variable name="teistructureelements">p|div|s|lg|sp|table|row|cell|figure|list|item</xsl:variable>

<xsl:template name="note-resp">
<xsl:if test="@resp">
<xsl:attribute name="class">resp_<xsl:value-of select="@resp"/></xsl:attribute>
</xsl:if>
</xsl:template>


<xsl:template name="metadata_link">
  <xsl:variable name="inst"><xsl:value-of select="./@xml:id"/></xsl:variable>
  <xsl:if test="//interpGrp[@inst=concat('#',$inst)]">
   <xsl:attribute name="metadata"><xsl:value-of select="./@xml:id"/></xsl:attribute>
  </xsl:if>
</xsl:template>

<xsl:param name='generateIds'>true</xsl:param><!-- We actually rarely do this now -->



<!--
 text nodes, inline tags en ignorable tagging binnen t.
  Let op: extra if ook in dergelijke andere templates toevoegen
  Of liever parametriseren
-->

<!-- meer algemeen iets met inline elementen doen wat je hier met hi en name doet -->







<xsl:template match="signed">
<xsl:apply-templates/>
</xsl:template>






<!-- *************************************************** DOCUMENT & METADATA ************************************************** -->

<xsl:template match="TEI|TEI.2">
<FoLiA xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://ilk.uvt.nl/folia" version="2.0.4" generator="tei2folia.xsl">
  <xsl:attribute name="xml:id"><xsl:value-of select="$docid"/></xsl:attribute>
  <metadata>
    <xsl:call-template name="annotations"/>
    <xsl:call-template name="provenance"/>
    <xsl:for-each select=".//listBibl[@xml:id='inlMetadata']//interpGrp"><meta id="{./@type}"><xsl:apply-templates mode="meta"/></meta></xsl:for-each>
    <xsl:for-each select=".//listBibl[not(@xml:id='inlMetadata')]">
        <submetadata>
            <xsl:attribute name="xml:id"><xsl:value-of select="substring-after(.//interpGrp/@inst[position()=1],'#')"/></xsl:attribute>
            <xsl:for-each select=".//interpGrp"><meta id="{./@type}"><xsl:apply-templates/></meta></xsl:for-each>
       </submetadata>
    </xsl:for-each>
  </metadata>
  <text>
    <xsl:attribute name="xml:id"><xsl:value-of select="$docid"/>.text</xsl:attribute>
    <xsl:apply-templates select="//text/*" mode="structure"/>
  </text>
</FoLiA>
</xsl:template>

<xsl:template name="annotations">
 <annotations>
     <text-annotation>
         <annotator processor="proc.tei2folia.xsl"/>
     </text-annotation>
<!--
 <entity-annotation annotatortype="auto" set="unknown"/>
-->
  <division-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/division">
         <annotator processor="proc.tei2folia.xsl"/>
  </division-annotation>
  <xsl:if test="//p">
    <paragraph-annotation>
         <annotator processor="proc.tei2folia.xsl"/>
    </paragraph-annotation>
  </xsl:if>
  <xsl:if test="//s">
    <sentence-annotation>
         <annotator processor="proc.tei2folia.xsl"/>
    </sentence-annotation>
  </xsl:if>
  <xsl:if test="//w">
    <token-annotation>
         <annotator processor="proc.tei2folia.xsl"/>
    </token-annotation>
  </xsl:if>
  <xsl:if test="//list">
      <list-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/list">
         <annotator processor="proc.tei2folia.xsl"/>
      </list-annotation>
  </xsl:if>
  <xsl:if test="//figure">
    <figure-annotation>
         <annotator processor="proc.tei2folia.xsl"/>
    </figure-annotation>
  </xsl:if>
  <xsl:if test="//table">
    <table-annotation>
         <annotator processor="proc.tei2folia.xsl"/>
    </table-annotation>
  </xsl:if>
  <xsl:if test="//text//gap|//text//label">
   <gap-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/gap">
         <annotator processor="proc.tei2folia.xsl"/>
   </gap-annotation>
  </xsl:if>
  <xsl:if test="//hi">
   <style-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/style">
         <annotator processor="proc.tei2folia.xsl"/>
   </style-annotation>
 </xsl:if>
 <part-annotation annotatortype="auto" set="http://rdf.ivdnt.org/nederlab/folia/sets/part"> <!-- we can't be sure if we use this, we try to avoid it as much as possible -->
         <annotator processor="proc.tei2folia.xsl"/>
 </part-annotation>
 <xsl:if test="//w/@pos">
  <pos-annotation set="unknown">
         <annotator processor="proc.tei2folia.xsl"/>
  </pos-annotation>
 </xsl:if>
 <xsl:if test="//w/@lemma">
  <lemma-annotation set="unknown">
         <annotator processor="proc.tei2folia.xsl"/>
  </lemma-annotation>
 </xsl:if>
<xsl:if test="//text//cor|//text//supplied|//text//del">
 <correction-annotation annotatortype="auto" set="http://rdf.ivdnt.org/nederlab/folia/sets/correction">
         <annotator processor="proc.tei2folia.xsl"/>
 </correction-annotation>
</xsl:if>
<xsl:if test="//text//note">
 <note-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/note">
         <annotator processor="proc.tei2folia.xsl"/>
 </note-annotation>
</xsl:if>
 <string-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/string">
         <annotator processor="proc.tei2folia.xsl"/>
 </string-annotation>
<xsl:if test="//sp|//stage">
 <event-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/events">
         <annotator processor="proc.tei2folia.xsl"/>
 </event-annotation>
</xsl:if>
<xsl:if test="//lb|//pb">
 <linebreak-annotation set="http://rdf.ivdnt.org/nederlab/folia/sets/linebreak">
         <annotator processor="proc.tei2folia.xsl"/>
 </linebreak-annotation>
</xsl:if>
   </annotations>
</xsl:template>

<xsl:template name="provenance">
   <provenance>
    <processor xml:id="proc.tei2folia" name="tei2folia" version="0.7.7" host="${host}" user="${user}" src="https://github.com/proycon/foliatools">
        <processor xml:id="proc.tei2folia.xsl" name="tei2folia.xsl" />
    </processor>
   </provenance>
</xsl:template>

<xsl:template match="interpGrp/interp" mode="meta"><xsl:variable name="cur"><xsl:value-of select="."/></xsl:variable><xsl:if test="not(../interp[1]=$cur)">|</xsl:if><xsl:apply-templates mode="meta"/></xsl:template>

<xsl:template match="interpGrp/text()" mode="meta"/>

<xsl:template match="interp/text()" mode="meta"><xsl:value-of select="normalize-space(.)"/></xsl:template>

<!-- ************************** HELPER TEMPLATES  *********************** -->

<!-- figure out if we need a text node -->
<xsl:template name="textandorstructure">
    <xsl:choose>
        <xsl:when test="text()|hi|pb|add|name|note|corr|supplied|add|del">
            <xsl:choose>
                <xsl:when test="p|div|s|lg|sp|table|row|cell|figure|list|item">
                    <!-- there are structural elements as well, we need to make sure they don't end up in <t> -->
                    <part>
                        <t><xsl:apply-templates mode="markup" /></t>
                    </part>
                    <xsl:apply-templates mode="structure" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- all is text markup, good -->
                    <t><xsl:apply-templates mode="markup" /></t>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="p|div|s|lg|sp|table|row|cell|figure|list|item">
            <!-- structure only, easy -->
            <xsl:apply-templates mode="structure" />
        </xsl:when>
    </xsl:choose>
</xsl:template>


<xsl:template name="pLike">
    <xsl:text>
    </xsl:text>
    <p>
    <xsl:attribute name="class"><xsl:value-of select="name(.)"/></xsl:attribute>
    <xsl:call-template name="textandorstructure"/>
    </p>
</xsl:template>

<!-- Sentence ID -->
<xsl:template name="setId">
 <xsl:if test="@xml:id or $generateIds='true'">
    <xsl:attribute name="xml:id">
        <xsl:choose>
            <xsl:when test="@ID"><xsl:value-of select="@xml:id"/></xsl:when>
            <xsl:otherwise>e<xsl:number level="any" count="*"/></xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>
 </xsl:if>
</xsl:template>

<!-- ************************** TEMPLATES PRODUCING STRUCTURAL ELEMENTS  *********************** -->

<xsl:template match="front|body|back" mode="structure">
    <div class="{name(.)}matter">
    <xsl:call-template name="haalPbBinnen"/>
    <xsl:apply-templates mode="structure" />
    </div>
</xsl:template>

<xsl:template match="head|docTitle|titlePart[not(ancestor::docTitle)]" mode="structure">
    <head>
    <xsl:attribute name="class">
    <xsl:choose>
        <xsl:when test="@rend"><xsl:value-of select="@rend"/></xsl:when>
        <xsl:otherwise>unspecified</xsl:otherwise>
    </xsl:choose>
    </xsl:attribute>
    <xsl:call-template name="textandorstructure"/>
    </head>
</xsl:template>


<xsl:template match="cell" mode="structure">
    <cell>
        <xsl:call-template name="haalPbBinnenInCel"/>
        <xsl:call-template name="textandorstructure"/>
    </cell>
</xsl:template>

<xsl:template match="p|speaker|trailer|closer|opener|lxx" mode="structure">
    <xsl:call-template name="pLike"/>
</xsl:template>


<xsl:template match="figure" mode="structure">
    <figure>
        <xsl:if test="xptr">
        <xsl:attribute name="src"><xsl:value-of select="xptr/@to" /></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="figDesc" mode="structure"/>
    </figure>
</xsl:template>

<xsl:template match="figDesc" mode="structure">
    <caption>
    <xsl:call-template name="textandorstructure"/>
    </caption>
</xsl:template>

<xsl:template match="list" mode="structure">
    <list>
        <xsl:apply-templates mode="structure"/>
    </list>
</xsl:template>

<!-- Handles both tei:item and preceding tei:label, in list context -->
<xsl:template match="item" mode="structure">
     <xsl:choose>
      <xsl:when test="name(preceding-sibling::*[1]) = 'label'">
        <item>
        <xsl:attribute name="n"><xsl:value-of select="string(preceding-sibling::*[1])" /></xsl:attribute>
        <t><t-gap class="label"><xsl:value-of select="string(preceding-sibling::*[1])" /></t-gap><xsl:text> </xsl:text> <xsl:apply-templates mode="markup"/></t>
        </item>
      </xsl:when>
      <xsl:otherwise>
        <item>
        <xsl:call-template name="textandorstructure" />
        </item>
     </xsl:otherwise>
</xsl:choose>
</xsl:template>



<xsl:template match="lg" mode="structure">
    <xsl:text>
    </xsl:text>
    <div>
    <xsl:attribute name="class"><xsl:choose><xsl:when test="@type"><xsl:value-of select="@type" /></xsl:when><xsl:otherwise>linegroup</xsl:otherwise></xsl:choose></xsl:attribute>
    <xsl:call-template name="textandorstructure" />
    </div>
</xsl:template>

<xsl:template match="epigraph" mode="structure">
    <div class="epigraph">
    <xsl:call-template name="textandorstructure" />
    </div>
</xsl:template>

<xsl:template match="table|row" mode="structure">
    <xsl:element name="{name(.)}">
    <xsl:apply-templates mode="structure" />
    </xsl:element>
</xsl:template>

<xsl:template match="div|div0|div1|div2|div3|div4|div5|div6|div7|titlePage|argument" mode="structure">
 <xsl:element name="div">
    <xsl:attribute name="class"><xsl:choose><xsl:when test="@type"><xsl:value-of select="@type" /></xsl:when><xsl:otherwise>unspecified</xsl:otherwise></xsl:choose></xsl:attribute>
    <xsl:call-template name="metadata_link"/>
    <xsl:call-template name="haalPbNietBinnen"/>
    <xsl:apply-templates mode="structure" />
 </xsl:element>
</xsl:template>


<!-- Valid both as structural and as markup, easy -->
<xsl:template match="lb" mode="structure"><br class="linebreak"/></xsl:template>
<xsl:template match="cb" mode="structure"><br class="columnbreak"/></xsl:template>
<xsl:template match="pb" mode="structure"><br class="pagebreak" newpage="yes" pagenr="{@n}"/></xsl:template>

<!-- ************************** TEMPLATES PRODUCING MARKUP ELEMENTS  *********************** -->

<xsl:template match="p//quote|p//q" mode="markup">
<t-str class="quote">
<xsl:apply-templates mode="markup" />
</t-str>
</xsl:template>

<xsl:template match="name" mode="markup">
<t-str class="name">
<xsl:choose>
<xsl:when test="@type">
<xsl:attribute name="class"><xsl:value-of select="@type"/>-name</xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="class">name</xsl:attribute>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates mode="markup"/>
</t-str>
</xsl:template>

<xsl:template match="add" mode="markup">
<t-str class="addition">
<xsl:apply-templates mode="markup" />
</t-str>
</xsl:template>

<!-- styling (tei:hi) -->
<xsl:template match="hi" mode="markup">
<t-style><xsl:attribute name="class"><xsl:choose><xsl:when test="@rendition"><xsl:value-of select="@rendition"/></xsl:when><xsl:when test="@rend"><xsl:value-of select="@rend"/></xsl:when><xsl:otherwise>unspecified</xsl:otherwise></xsl:choose></xsl:attribute><xsl:apply-templates mode="markup"/></t-style>
</xsl:template>


<!-- Valid both as structural and as markup, easy -->
<xsl:template match="lb" mode="markup"><br class="linebreak"/></xsl:template>
<xsl:template match="cb" mode="markup"><br class="columnbreak"/></xsl:template>
<xsl:template match="pb" mode="markup"><br class="pagebreak" newpage="yes" pagenr="{@n}"/></xsl:template>


<!-- Corrections -->
<!-- TODO: annotators should be in provenance chain, specifying them here probably fails even now -->
<xsl:template match="corr"><t-correction class="correction" annotator="{@resp}" original="{@sic}"><xsl:apply-templates mode="markup"/></t-correction></xsl:template>

<xsl:template match="supplied"><t-correction class="supplied" annotator="{@resp}"><xsl:apply-templates mode="markup"/></t-correction></xsl:template>

<xsl:template match="del"><t-correction class="deletion" annotator="{@resp}" original="{.//text()}"></t-correction></xsl:template>

<!-- Notes -->
<xsl:template match="note" mode="markup">
<t-gap class="note" n="{@n}"><xsl:value-of select="text()" /></t-gap>
</xsl:template>


<xsl:template match="note[./table|./figure|./list|./p]" mode="markup">
<xsl:message>WARNING: There is a table, list or figure or paragraph in a note, the converter can't handle this currently</xsl:message>
<t-gap class="unprocessable-note" n="{@n}"/>
</xsl:template>

<!-- ************************** TEMPLATES PRODUCING STRUCTURAL AND MARKUP ELEMENTS, CONDITIONALLY  *********************** -->

<xsl:template match="q|quote" mode="structure">
    <quote>
    <xsl:call-template name="textandorstructure" />
    </quote>
</xsl:template>

<xsl:template match="q|quote" mode="markup">
<t-str class="quote"><xsl:apply-templates mode="markup" /></t-str>
</xsl:template>

<xsl:template match="gap" mode="markup">
    <t-gap annotator="{@resp}" class="{@reason}"/>
</xsl:template>

<xsl:template match="gap" mode="structure">
    <gap annotator="{@resp}" class="{@reason}"/>
</xsl:template>

<xsl:template match="l" mode="markup">
    <t-str class="l"><xsl:if test="@n"><xsl:attribute name="n"><xsl:value-of select="@n" /></xsl:attribute></xsl:if><xsl:apply-templates mode="markup"/></t-str><br class='poetic.linebreak'><xsl:if test="@n"><xsl:attribute name="n"><xsl:value-of select="@n" /></xsl:attribute></xsl:if></br><xsl:text>&#10;</xsl:text>
</xsl:template>



<!-- ************************** TEMPLATES DELETING ELEMENTS  *********************** -->

<!-- Deletion often occurs because the element is already handled elsewhere -->

<xsl:template match="docTitle/titlePart"><xsl:apply-templates/></xsl:template>

<!-- I suppose this cleans up something from some preprocessing step? leaving it in just in case -->
<xsl:template match="supplied[./text()='leeg']"/>

<!-- Handled by item -->
<xsl:template match="label"/>

<xsl:template match="anchor"/>


<!-- *********************************** PAGEBREAK MAGIC **************************************************** -->

<!-- I'm not entirely sure what this does but it looks well thought out (proycon) -->

<!--
<xsl:template match="pb|div//pb|div1//pb|div2//pb|div3//pb|titlePage//pb|p//pb|trailer//pb|closer//pb">
<xsl:call-template name="pb"/>
</xsl:template>

<xsl:template match="pb/maarnietechthoor">
<xsl:if test="not (ancestor::div or ancestor::div1 or ancestor::titlePage or ancestor::p) and (following-sibling::*[1][self::div or self::div1 or self::div2 or self::div3 or self::titlePage])">
<xsl:comment>verplaatste pagebreak</xsl:comment>
</xsl:if>
<xsl:if test="ancestor::div or ancestor::titlePage or ancestor::div1">
<xsl:comment>legale pagebreak</xsl:comment>
</xsl:if>
<xsl:if test="not (ancestor::div or ancestor::div1 or ancestor::titlePage or ancestor::pb) and not(following-sibling::*[1][self::div or self::div1 or self::div2 or self::div3 or self::titlePage])">
<xsl:comment>verloren pagebreak</xsl:comment>
</xsl:if>
</xsl:template>
-->

<xsl:template name="haalPbNietBinnen"/>

<xsl:template name="haalPbBinnen">
<xsl:for-each select="preceding-sibling::*[1]">
<xsl:if test="self::pb and (not(ancestor::div)) and (not(ancestor::div1))  and (not(ancestor::titlePage))">
<xsl:comment>opgeviste pagebreak:</xsl:comment>
<xsl:call-template name="pb"/>
</xsl:if>
</xsl:for-each>
</xsl:template>



<xsl:template name="haalPbBinnenInCel">
<xsl:for-each select="..">
<xsl:for-each select="preceding-sibling::*[1]">
<xsl:if test="self::pb">
<xsl:comment>opgeviste pagebreak naar cel</xsl:comment>
<xsl:call-template name="pb"/>
</xsl:if>
</xsl:for-each>
</xsl:for-each>
</xsl:template>

<xsl:template match="text/pb|table/pb|row/pb|list/lb"><xsl:comment>Deze pagebreak doen we mooi niet hoor!</xsl:comment></xsl:template>

<!-- ********************************* CRUFT ****************************************************** -->



<!-- disabled XSLT 2.0 (proycon)
<xsl:template match="p[./table|./figure|./list]|xcloser[./list]|xcloser[./signed/list]">
<xsl:for-each-group select="node()" group-ending-with="table">
<p>
<t><xsl:apply-templates select="current-group()[not(self::table or self::figure or self::list or self::signed)]"/></t>
</p>
<xsl:apply-templates select="current-group()[self::table or self::figure or self::list or self::signed]"/>
</xsl:for-each-group>
</xsl:template>
-->



<!-- disabled because of XSLT2.0 (proycon)
<xsl:template match="hi[./lb]">
<xsl:variable name="class"><xsl:value-of select="@rendition"/><xsl:value-of select="@rend"/></xsl:variable>
<xsl:for-each-group select="node()" group-ending-with="lb">
<t-style class="{$class}">
<xsl:apply-templates select="current-group()[not(self::lb)]"/>
</t-style>
<xsl:apply-templates select="current-group()[self::lb]"/>
</xsl:for-each-group>
</xsl:template>
-->




<xsl:template match="delSpan">
<xsl:variable name="spanTo"><xsl:value-of select="@spanTo"/></xsl:variable>
<xsl:variable name="end"><xsl:value-of select="following-sibling::anchor[@xml:id=$spanTo]"/></xsl:variable>
<xsl:if test="$end">
<xsl:message>Deleted text: (<xsl:value-of select="name($end)"/>) <xsl:value-of select="$end/preceding-sibling::node()[preceding-sibling::delSpan[@spanTo=$spanTo]]"/>
</xsl:message>
</xsl:if>
</xsl:template>


<xsl:template match="sp" mode="structure">
<xsl:text>
</xsl:text>
<event class="speakerturn">
<xsl:choose>
<xsl:when test=".//speaker/hi">
    <xsl:attribute name="actor"><xsl:value-of select="string(.//speaker/hi)" /></xsl:attribute>
    <xsl:apply-templates select="speaker" mode="structure" />
</xsl:when>
<xsl:when test=".//speaker">
    <xsl:attribute name="actor"><xsl:value-of select="string(.//speaker)" /></xsl:attribute>
    <xsl:apply-templates select="speaker" mode="structure" />
</xsl:when>
</xsl:choose>
</event>
</xsl:template>

<xsl:template match="stage" mode="structure">
<event class="stage">
    <xsl:call-template name="textandorstructure"/>
</event>
</xsl:template>



<xsl:template match="add[@resp='transcriber']"/>

<xsl:template match="p//add">
<xsl:message>JAWEL, HET KOMT WEL VOOR!!!!</xsl:message>
<note class="add" annotator="@resp">
<t>
<xsl:apply-templates/>
</t>
</note>
</xsl:template>

<!-- ********************************** WARNINGS ***************************************************** -->

<xsl:template match="*" mode="structure">
    <xsl:message>WARNING: Unknown tag in structure context: <xsl:value-of select="name(.)"/> (in <xsl:value-of select="name(parent::node())" />)</xsl:message>
    <xsl:comment>[tei2folia WARNING] Unhandled tag in structure context: <xsl:value-of select="name(.)"/> (in <xsl:value-of select="name(parent::node())" />)</xsl:comment>
</xsl:template>

<xsl:template match="*" mode="markup">
<xsl:message>WARNING: Unknown tag in markup context: <xsl:value-of select="name(.)"/> (in <xsl:value-of select="name(parent::node())" />)</xsl:message>
<xsl:comment>[tei2folia WARNING] Unhandled tag in markup context: tei:<xsl:value-of select="name(.)"/> (in tei:<xsl:value-of select="name(parent::node())" />)</xsl:comment>
</xsl:template>

<xsl:template match="*">
<xsl:message>WARNING: Unknown tag: <xsl:value-of select="name(.)"/> (in <xsl:value-of select="name(parent::node())" />)</xsl:message>
<xsl:comment>[tei2folia WARNING] Unhandled tag: tei:<xsl:value-of select="name(.)"/> (in tei:<xsl:value-of select="name(parent::node())" />)</xsl:comment>
</xsl:template>


</xsl:stylesheet>