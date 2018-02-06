<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    
<!-- This transformation replicates the original Sente XML -->
    
    <xsl:template match="TEI">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:biblStruct">
        
    </xsl:template>
    
    <!-- Create Sente reference for each div -->
    <xsl:template match="div">
        <xsl:element name="tss:reference"/>
        <xsl:element name="tss:characteristics">
            <xsl:call-template name="templID"/>
            <xsl:apply-templates select="note[@type='abstract']"/>
        </xsl:element>
        <xsl:apply-templates select=".//tss:keywords"/>
    </xsl:template>
    
    <!-- Abstract -->
    <xsl:template match="note[@type='abstract']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">abstractText</xsl:attribute>
            <!-- In order to preserve existing markup copy-of must be chosen -->
            <xsl:copy-of select="./node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- IDs -->
    <xsl:template name="templID">
        <xsl:apply-templates select=".//idno[@type='BibTex']"/>
        <xsl:apply-templates select=".//idno[@type='RIS reference number']"/>
        <xsl:apply-templates select=".//idno[@type='OCLCID']"/>
        <xsl:apply-templates select=".//idno[@type='SenteUUID']"/>
        <xsl:apply-templates select=".//idno[@type='CitationID']"/>
        <xsl:apply-templates select=".//idno[@type='callNumber']"/>
    </xsl:template>
    
    <xsl:template match="idno[@type='BibTex']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">BibTex cite tag</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="idno[@type='RIS reference number']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">RIS reference number</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="idno[@type='OCLCID']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">OCLCID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="idno[@type='SenteUUID']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">UUID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="idno[@type='CitationID']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Citation identifier</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="idno[@type='callNumber']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">call-Num</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
   
    <!-- Keywords/Tags -->
    <!-- This transformation replicates the original Sente XML -->
    <xsl:template match="tss:keywords">
            <xsl:element name="tss:keywords">
                <xsl:apply-templates select=".//tss:keyword"/>
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
