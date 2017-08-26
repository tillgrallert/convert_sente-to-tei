<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

<!-- Correct structure for the autput, sorting of elements -->
 <xsl:template match="tss:reference">
     <xsl:element name="div">
         <xsl:call-template name="templXmlId"/>
        <xsl:element name="biblStruct">
            <!-- according to TEI the levels of analytic, monogr, and series depend
                on the publication type -->
            <xsl:choose>
            <xsl:when test=".//tss:publicationType[@name='Newspaper article']">
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
                <xsl:apply-templates select=".//tss:characteristic[@name='publicationTitle']"/>
                <xsl:apply-templates select=".//tss:characteristic[@name='articleTitle']"/>
                <xsl:call-template name="templImprint"/>
                </xsl:element>
            </xsl:otherwise>
            </xsl:choose>
               <xsl:call-template name="templId"/>
            </xsl:element>

            <xsl:call-template name="templAbstract"/>
            <!-- characteristics still unaccounted for-->

            <xsl:apply-templates select=".//tss:keywords"/>
            
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
 <!-- Imprint -->  
<xsl:template name="templImprint">
    <xsl:element name="imprint">
        <xsl:apply-templates select=".//tss:characteristic[@name='publisher']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='publicationCountry']"/>
        <xsl:apply-templates select=".//tss:date[@type='Publication']"/>
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
                    This must be changed through some function, as TEI requires 
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
            <xsl:element name="note">
                <xsl:attribute name="type">abstract</xsl:attribute>
                <!-- In order to preserve existing markup copy-of must be chosen -->   
                <xsl:copy-of select=".//tss:characteristic[@name='abstractText']/node()"/>
            </xsl:element>
    </xsl:template>

<!-- IDs -->
    <xsl:template name="templXmlId">
        <xsl:attribute name="name">
            <!--<xsl:call-template name="SenteUUID2XmlID"/>-->
            <xsl:value-of select=".//tss:characteristic[@name='UUID']"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="templId">
        <xsl:apply-templates select="tss:characteristic[@name='UUID']"/>
        <xsl:call-template name="templSignatur"/>
        <xsl:apply-templates select="tss:characteristic[@name='Citation identifier']"/>
        <xsl:apply-templates select="tss:characteristic[@name='OCLCID']"/>
        <xsl:apply-templates select="tss:characteristic[@name='RIS reference number']"></xsl:apply-templates>
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

<!-- Notes -->
<!-- Quotes -->
   
 <!-- Keywords/Tags -->
    <!-- This transformation replicates the original Sente XML -->
    <xsl:template match="tss:keywords">
        <xsl:element name="note">
            <xsl:attribute name="type">keywords</xsl:attribute>
            <!--<xsl:attribute name="xml:id">
                <xsl:value-of select="..//tss:characteristic[@name='UUID']"/>
                </xsl:attribute>-->
            <xsl:element name="tss:keywords">
                <xsl:apply-templates select=".//tss:keyword"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tss:keyword">
        <xsl:element name="tss:keyword">
            <!-- The assigner should be retained -->
            <xsl:attribute name="assigner">
                <xsl:value-of select="@assigner"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

<!-- Replacement functions -->
    <xsl:template name="SenteUUID2XmlID">
        <xsl:param name="string" select=".//tss:characteristic[@name='UUID']"/>
        <xsl:variable name="dash" select='"-"' />
        <xsl:choose>
            <xsl:when test='contains($string, $dash)'>
                <!-- value-of strips all xml markup from the string -->
                <xsl:copy-of
                    select="substring-before($string, $dash)" copy-namespaces="no"/>
                <xsl:call-template name="SenteUUID2XmlID">
                    <xsl:with-param name="string"
                        select="substring-after($string, $dash)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$string" copy-namespaces="no"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- Still missing fields -->
    <xsl:template match="tss:publicationType">
        <xsl:element name="tss:publicationType">
            <xsl:attribute name="name">
        <xsl:value-of select="@name"/>
            </xsl:attribute>
        </xsl:element>   
    </xsl:template>   
    <xsl:template match="tss:characteristic[@name='affiliation']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">affiliation</xsl:attribute>
        <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='language']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">language</xsl:attribute>
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
    <xsl:template match="tss:characteristic[@name='Recipient']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Recipient</xsl:attribute>
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
    <xsl:template match="tss:characteristic[@name='Date Rumi']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Date Rumi</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Date Hijri']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Date Hijri</xsl:attribute>
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



