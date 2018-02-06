<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- this stylesheet transforms references from SenteXML into biblStruct elements of a TEI P5 xml -->
    <!-- to be done: include the URL field and the URI to the attachments -->
    <!-- v3b: includes the URL as @facs of the biblStruct element -->

<!-- Correct structure for the autput, sorting of elements -->
 <xsl:template match="tss:references">
     <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
         <xsl:call-template name="templTeiHeader"/><!-- at the moment this only works for archival material -->
         <xsl:element name="text">
             <xsl:element name="body">

     <xsl:apply-templates select="./tss:reference">
         <!-- here one could select all sort of sorting criteria -->
         <!-- <xsl:sort select=".//tss:date[@type='Publication']"/> -->
         <!-- <xsl:sort select="./tss:author"/> -->
         <xsl:sort select=".//tss:characteristic[@name='publicationTitle']"/>
         <xsl:sort select=".//tss:characteristic[@name='volume']"/>
     </xsl:apply-templates>
             </xsl:element>
         </xsl:element>
     </xsl:element>
 </xsl:template>

    <xsl:template match="tss:reference">  
     <xsl:element name="div">
        <xsl:call-template name="templXmlId"/>
        <xsl:call-template name="templType"/>
        <xsl:element name="biblStruct">
            <xsl:call-template name="templLang"/>
            <xsl:if test=".//tss:characteristic[@name='URL']">
                <xsl:attribute name="facs">
                    <xsl:value-of select=".//tss:characteristic[@name='URL']"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test=".//tss:attachmentReference/URL">
                <xsl:attribute name="facs">
                    <xsl:value-of select=".//tss:attachmentReference[1]/URL[1]"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test=".//tss:publicationType[@name='Newspaper article'] or .//tss:publicationType[@name='Archival Periodical Article']">
                <xsl:element name="analytic">
                  <xsl:apply-templates select=".//tss:author[@role='Author']"/>
                  <xsl:apply-templates select=".//tss:characteristic[@name='articleTitle']"/>  
                </xsl:element>
                <xsl:element name="monogr">
                <xsl:apply-templates select=".//tss:author[@role='Editor']"/>
                <xsl:apply-templates select=".//tss:characteristic[@name='publicationTitle']"/>
                <xsl:call-template name="templImprint"/>
                </xsl:element>
            </xsl:when>
                
            <xsl:otherwise>
                <xsl:element name="monogr">
                <xsl:apply-templates select=".//tss:author[@role='Author']"/>
                <xsl:apply-templates select=".//tss:author[@role='Editor']"/>
                <xsl:apply-templates select=".//tss:characteristic[@name='Recipient']"/>
                <xsl:apply-templates select=".//tss:characteristic[@name='publicationTitle']"/>
                <xsl:apply-templates select=".//tss:characteristic[@name='articleTitle']"/>
                <xsl:call-template name="templImprint"/>
                </xsl:element>
            </xsl:otherwise>
            </xsl:choose>
               <xsl:call-template name="templId"/>
            </xsl:element>

            <xsl:call-template name="templAbstract"/>
            <xsl:apply-templates select=".//tss:keywords"/>
            <xsl:apply-templates select=".//tss:notes"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="templTeiHeader">
        <xsl:element name="teiHeader">
            <xsl:element name="fileDesc">
                <xsl:element name="titleStmt">
                    <xsl:element name="title">
                        <!-- the current file name should be added here -->
                        <xsl:value-of select=".//tss:reference[1]//tss:characteristic[@name='Repository']"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select=".//tss:reference[1]//tss:characteristic[@name='Signatur']"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="publicationStmt">
                    <xsl:element name="p">
                        <xsl:text>This should be replaced with some description</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="sourceDesc">
                    <xsl:element name="p">
                        <xsl:value-of select=".//tss:reference[1]//tss:publicationType/@name"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    
<!-- Contributors to the source/reference -->
    <xsl:template match="tss:author[@role='Author']">
    <xsl:element name="author">
        <xsl:element name="surname">
            <xsl:value-of select="tss:surname"/>
        </xsl:element>
        <xsl:element name="forename">
            <xsl:value-of select="tss:forenames"/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template match="tss:author[@role='Editor']">
    <xsl:element name="editor">
        <xsl:element name="surname">
            <xsl:value-of select="tss:surname"/>
        </xsl:element>
        <xsl:element name="forename">
            <xsl:value-of select="tss:forenames"/>
        </xsl:element>
    </xsl:element>
</xsl:template>
    
<!-- Recipient -->
    <xsl:template match="tss:characteristic[@name='Recipient']">
        <xsl:element name="respStmt">
            <xsl:element name="resp">recipient</xsl:element>
            <xsl:element name="persName">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
 <!-- Imprint -->  
<xsl:template name="templImprint">
    <xsl:element name="imprint">
        <xsl:apply-templates select=".//tss:characteristic[@name='publisher']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='publicationCountry']"/>
        <xsl:apply-templates select=".//tss:date[@type='Publication']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='Date Hijri']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='Date Rumi']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='volume']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='issue']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='pages']"/>
    </xsl:element>
</xsl:template>
    
    <!-- Publisher -->
          <xsl:template match="tss:characteristic[@name='publisher']">
            <xsl:element name="publisher">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:template>  
    <!-- Place of publication -->
        <xsl:template match="tss:characteristic[@name='publicationCountry']">
            <xsl:element name="pubPlace">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:template>
    <!-- Pages -->
    <xsl:template match="tss:characteristic[@name='pages']">
            <xsl:element name="biblScope">
                <xsl:attribute name="type">pp</xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
    </xsl:template>
    <!-- Volume -->
    <xsl:template match="tss:characteristic[@name='volume']">
            <xsl:element name="biblScope">
                <xsl:attribute name="type">vol</xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
    </xsl:template>
    <!-- Issue -->
    <xsl:template match="tss:characteristic[@name='issue']">
        <xsl:element name="biblScope">
            <xsl:attribute name="type">issue</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Dates -->
    <xsl:template match="tss:date[@type='Publication']">
            <xsl:element name="date">
                <xsl:attribute name="calendar">Gregorian</xsl:attribute>
                <xsl:attribute name="when">
                <xsl:choose>
                    <xsl:when test="./@year">
                      <xsl:value-of select="./@year"/>   
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:text>-</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- SenteXML produces single digit months and days if applicable. 
                    This must be changed, as TEI requires 
                    ISO-compliant dates. -->
                       <xsl:if test="string-length (./@month)=2">
                           <xsl:text>-</xsl:text>
                           <xsl:value-of select="./@month"/>
                       </xsl:if>
                       <xsl:if test="string-length (./@month)=1">
                           <xsl:text>-0</xsl:text>
                           <xsl:value-of select="./@month"/>
                       </xsl:if>
                       <xsl:if test="string-length (./@day)=2">
                           <xsl:text>-</xsl:text>
                           <xsl:value-of select="./@day"/>
                       </xsl:if>
                       <xsl:if test="string-length (./@day)=1">
                           <xsl:text>-0</xsl:text>
                           <xsl:value-of select="./@day"/>
                       </xsl:if>
                </xsl:attribute>
                <!-- Probably human-readable output as text would make sense here -->
            </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Date Rumi']">
        <xsl:element name="date">
            <xsl:attribute name="type">Rumi</xsl:attribute>
            <xsl:attribute name="calendar">Julian</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Date Hijri']">
        <xsl:element name="date">
            <xsl:attribute name="type">Hijri</xsl:attribute>
            <xsl:attribute name="calendar">Islamic</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
        
<!-- Titles -->
    <xsl:template match="tss:characteristic[@name='publicationTitle']">
            <xsl:element name="title">
                <xsl:value-of select="."/>
            </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='articleTitle']">
           <xsl:element name="title">
                <xsl:attribute name="level">a</xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:template>
    
<!-- Abstract -->
    <xsl:template name="templAbstract">        
            <xsl:element name="div">
                <xsl:attribute name="type">abstract</xsl:attribute>
                <xsl:element name="p">
                <!-- In order to preserve existing markup copy-of must be chosen -->   
                <xsl:copy-of select=".//tss:characteristic[@name='abstractText']/node()"/>
                </xsl:element>
            </xsl:element>
    </xsl:template>

<!-- IDs -->
    <xsl:template name="templXmlId">
        <xsl:if test=".//tss:characteristic[@name='UUID']">
        <xsl:attribute name="xml:id">
            <!-- xml:ids cannot start with a number! why? -->
            <xsl:text>uuid_</xsl:text>
            <!-- as xml:ids cannot contain dashes etc. we have to get rid of them -->
            <xsl:call-template name="templReplaceString">
                <xsl:with-param name="pString" select=".//tss:characteristic[@name='UUID']"/>
                <xsl:with-param name="pFind" select="'-'"/>
                <xsl:with-param name="pReplace" select="'_'"/>
            </xsl:call-template>
            <!-- <xsl:value-of select=".//tss:characteristic[@name='UUID']"/> -->
            <!--<xsl:call-template name="SenteUUID2XmlID"/>-->
        </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="templId">
        <xsl:apply-templates select="tss:characteristic[@name='UUID']"/>
        <xsl:call-template name="templSignatur"/>
        <xsl:if test=".//tss:publicationType[@name='Archival File'] or .//tss:publicationType[@name='Archival Letter'] or .//tss:publicationType[@name='Archival Material'] or .//tss:publicationType[@name='Archival Journal Entry']">
            <xsl:call-template name="templArcchivalCM"/>
        </xsl:if>
        <xsl:apply-templates select="tss:characteristic[@name='Citation identifier']"/>
        <xsl:apply-templates select="tss:characteristic[@name='OCLCID']"/>
        <xsl:apply-templates select="tss:characteristic[@name='RIS reference number']"/>
    </xsl:template>

    <xsl:template match="tss:characteristic[@name='BibTeX cite tag']">
        <xsl:element name="idno">
            <xsl:attribute name="type">BibTex</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='RIS reference number']">
        <xsl:element name="idno">
            <xsl:attribute name="type">RIS reference number</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='OCLCID']">
        <xsl:element name="idno">
            <xsl:attribute name="type">OCLCID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Sente UUID -->
    <xsl:template match="tss:characteristic[@name='UUID']">
        <xsl:element name="idno">
            <!-- Supposedly XML names cannot contain whitespaces, thus, Sente UUID should be named SenteUUID -->
            <xsl:attribute name="type">SenteUUID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Sente ID -->
    <xsl:template match="tss:characteristic[@name='Citation identifier']">
        <xsl:element name="idno">
            <xsl:attribute name="type">CitationID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Signatur -->
    <xsl:template name="templSignatur" match="tss:characteristic[@name='Signatur']">
        <xsl:choose>
            <!-- Check if the Signatur, which is a custom field, matches the call-number -->
            <xsl:when test="compare(*//tss:characteristic[@name='Signatur'],*//tss:characteristic[@name='call-num'])=0">
                <xsl:call-template name="templCallNum"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- If the reference has no call number this field will be filled with Signatur data -->
                    <xsl:when test="*//tss:characteristic[@name='call-num']">
                        <xsl:element name="idno">
                            <xsl:attribute name="type">Signatur</xsl:attribute>
                            <xsl:value-of select="*//tss:characteristic[@name='Signatur']"/>
                        </xsl:element>
                        <xsl:call-template name="templCallNum"></xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="idno">
                            <xsl:attribute name="type">callNumber</xsl:attribute>
                            <xsl:value-of select="*//tss:characteristic[@name='Signatur']"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Call Number -->
    <xsl:template name="templCallNum" match="tss:characteristic[@name='call-num']">
        <xsl:element name="idno">
                <xsl:attribute name="type">callNumber</xsl:attribute>
                <xsl:value-of select="*//tss:characteristic[@name='call-num']"/>
        </xsl:element>
    </xsl:template>
    
    <!-- construct an archival class mark structure -->
    <xsl:template name="templArcchivalCM">
        <xsl:element name="idno">
            <xsl:attribute name="type">archival-class-mark</xsl:attribute>
                <xsl:value-of select=".//tss:characteristic[@name='Repository']"/>
                <xsl:if test=".//tss:characteristic[@name='Repository']"><xsl:text> </xsl:text></xsl:if>
                <xsl:value-of select=".//tss:characteristic[@name='Signatur']"/>
                <xsl:if test=".//tss:characteristic[@name='publicationCountry']"><xsl:text> </xsl:text></xsl:if>
                <xsl:value-of select=".//tss:characteristic[@name='publicationCountry']"/>
                <xsl:if test=".//tss:characteristic[@name='issue']"><xsl:text> </xsl:text></xsl:if>
                <xsl:value-of select=".//tss:characteristic[@name='issue']"/>
        </xsl:element>
    </xsl:template>

 <!-- Publication Type -->
 <!-- this should go as an attribute on the reference's div -->
<xsl:template name="templType">
        <xsl:attribute name="type">
            <xsl:call-template name="templReplaceString">
                <xsl:with-param name="pString" select=".//tss:publicationType/@name"/>
                <xsl:with-param name="pFind" select="' '"/>
                <xsl:with-param name="pReplace" select="'-'"/>
            </xsl:call-template>
        </xsl:attribute>
</xsl:template> 

<!-- Notes -->
<xsl:template match="tss:notes">
    <xsl:element name="div">
        <xsl:attribute name="type">notes</xsl:attribute>
            <xsl:for-each select=".//tss:note">
                <xsl:sort select="./tss:pages" data-type='text'/> <!-- the field contains mixed strings and page ranges-->
                <xsl:element name="div">
                    <xsl:attribute name="type">note</xsl:attribute>
                    <!-- I do not know whether @n must be unique -->
                    <xsl:attribute name="n">
                        <xsl:value-of select="./tss:pages"/>
                    </xsl:attribute>
                    <xsl:element name="head">
                        <xsl:value-of select=".//tss:title"/>
                    </xsl:element>
                    <xsl:element name="p">
                        <xsl:text>p.</xsl:text>
                        <xsl:value-of select=".//tss:pages"/>
                        <xsl:text>; </xsl:text>
                        <xsl:element name="quote">
                        <xsl:value-of select=".//tss:quotation"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="p">
                        <!-- @type is not allowed on p -->
                        <xsl:value-of select=".//tss:comment"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
</xsl:template>
   
<!-- Keywords/Tags -->
    <!-- This transformation replicates the original Sente XML -->
    <xsl:template match="tss:keywords">
        <xsl:element name="div">
            <xsl:attribute name="type">tags</xsl:attribute>
            <xsl:element name="tss:keywords">
                <xsl:for-each select=".//tss:keyword">
                    <xsl:sort select="." data-type="text" order="ascending"/>
                    <xsl:element name="tss:keyword">
                        <!-- The assigner should be retained -->
                        <xsl:attribute name="assigner">
                            <xsl:value-of select="@assigner"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>
   

<!-- Replacement functions -->
    <xsl:template name="templStripDashes">
        <xsl:param name="pString"/>
        <xsl:param name="pFind" select='"-"' />
        <xsl:choose>
            <xsl:when test='contains($pString, $pFind)'>
                <!-- value-of strips all xml markup from the string -->
                <xsl:copy-of
                    select="substring-before($pString, $pFind)" copy-namespaces="no"/>
                <xsl:call-template name="templStripDashes">
                    <xsl:with-param name="pString"
                        select="substring-after($pString, $pFind)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$pString" copy-namespaces="no"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="templReplaceString">
        <xsl:param name="pString"/>
        <xsl:param name="pFind"/>
        <xsl:param name="pReplace"/>
        <xsl:choose>
            <xsl:when test='contains($pString, $pFind)'>
                <!-- value-of strips all xml markup from the string -->
                <xsl:copy-of
                    select="substring-before($pString, $pFind)" copy-namespaces="no"/>
                <xsl:value-of select="$pReplace"/>
                <xsl:call-template name="templReplaceString">
                    <xsl:with-param name="pString"
                        select="substring-after($pString, $pFind)" />
                    <xsl:with-param name="pFind" select="$pFind"/>
                    <xsl:with-param name="pReplace" select="$pReplace"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$pString" copy-namespaces="no"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- Languages -->
    <!-- the @xml:lang elemnt in TEI must conform to BCP 47. 
        "ar" stands for Arabic language and "Arab" for Arabic script. Compounds can be formed with a dash. 
        Thus, Ottoman Turkish should be encoded as "tr-Arab"  -->
    <xsl:template name="templLang">
        <xsl:if test="lower-case(.//tss:characteristic[@name='language'])">
            <xsl:attribute name="xml:lang">
                <xsl:choose>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'arabic'">
                        <xsl:text>ar</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'french'">
                            <xsl:text>fr</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'ottoman turkish'">
                       <xsl:text>tr-Arab</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'ottoman'">
                            <xsl:text>tr-Arab</xsl:text>             
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'turkish'">
                            <xsl:text>tr</xsl:text>             
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'english'">
                        <xsl:text>en</xsl:text>             
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'german'">
                        <xsl:text>de</xsl:text>             
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    

        
<!-- Still missing fields -->  
    <xsl:template match="tss:characteristic[@name='affiliation']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">affiliation</xsl:attribute>
        <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='publicationStatus']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">publicationStatus</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='status']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">status</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Othertype']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Othertype</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Date read']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Date read</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Repository']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Repository</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Standort']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Standort</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Series number']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Series number</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Short Title']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Short Title</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Medium consulted']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Medium consulted</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='URL']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">URL</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Web data source']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Web data source</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>



</xsl:stylesheet>