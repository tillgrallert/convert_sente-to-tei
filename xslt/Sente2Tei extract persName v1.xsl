<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- this stylesheet produces a TEI XML file containig a listPerson with all strings marked as <persName>  (both escaped and not) in a Sente XML source file. The output also containes a <listNym> with all single-word forms tagged as persName but not found in the authority file for nyms ($pgNyms). -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>
   
    <xsl:param name="pgNyms" select="document('/BachUni/projekte/XML/TEI XML/master files/NymMasterTEI.xml')"/>
    
    <!-- templates dealing with Sente XML files -->
    <xsl:template match="tss:senteContainer">
        <xsl:result-document href="persNamesTempTEI {format-date(current-date(),'[Y01][M01][D01]')}.xml">
            <tei:TEI>
                <tei:teiHeader>
                    <tei:fileDesc>
                        <tei:titleStmt>
                            <tei:title>persNames from Sente XML</tei:title>
                            <tei:respStmt>
                                <tei:resp>Prepared by</tei:resp>
                                <tei:persName>Till Grallert</tei:persName>
                            </tei:respStmt>
                        </tei:titleStmt>
                        <tei:publicationStmt>
                            <xsl:element name="tei:p">Version of <xsl:value-of select="format-date(current-date(),'[D01] [MNn] [Y0001]')"/></xsl:element>
                        </tei:publicationStmt>
                        <tei:sourceDesc>
                            <xsl:apply-templates mode="mPers"/>
                            <!--<xsl:apply-templates select="descendant::tei:persName" mode="mPers"/>-->
                        </tei:sourceDesc>
                    </tei:fileDesc>
                    <tei:revisionDesc>
                        <xsl:element name="tei:change">
                            <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                            <xsl:text>File created from mark-up inside the Sente XML file "</xsl:text>
                            <xsl:value-of select="base-uri()"/>
                            <xsl:text>" through an XSLT conversion.</xsl:text>
                        </xsl:element>
                    </tei:revisionDesc>
                </tei:teiHeader>
                <tei:text>
                    <tei:body>
                        <tei:p>empty</tei:p>
                    </tei:body>
                </tei:text>
            </tei:TEI> 
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tss:library" mode="mPers">
        <!-- list of tagged persons -->
        <xsl:element name="tei:listPerson">
            <xsl:for-each-group select="$vPersNames/tei:persName" group-by=".">
                <xsl:sort select="." collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:element name="tei:person">
                    <xsl:copy-of select="."/>
                    <xsl:element name="tei:persName">
                        <xsl:attribute name="type" select="'simple'"/>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:element>
        <!-- list of unknown nyms -->
        <xsl:element name="tei:listNym">
            <xsl:for-each-group select="$vPersNames/tei:persName/tei:name[not(./@nymRef)]" group-by=".">
                <xsl:sort select="." collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:if test="not($pgNyms//tei:form=.)">
                    <xsl:element name="tei:nym">
                        <xsl:element name="tei:form">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>
    
    
    <!-- vPersNames extracts all persName nodes from the source file: both escaped and not. -->
    <xsl:variable name="vPersNames">
        <!-- deals with plain text mark-up -->
        <xsl:for-each select="if(contains(.,'&lt;/persName&gt;')) then(tokenize(., '&lt;/persName&gt;')) else()">
            <xsl:variable name="vPersName" select="if(substring(substring-after(., '&lt;persName&gt;'),1,1)=' ') then(substring(substring-after(., '&lt;persName&gt;'),2)) else(substring-after(., '&lt;persName&gt;'))"/>
            <xsl:element name="tei:persName">
                <xsl:value-of select="$vPersName"/>
            </xsl:element>
        </xsl:for-each>
        <!-- deals with proper xml -->
        <xsl:for-each select=".//tei:persName">
            <xsl:apply-templates select="." mode="mPers"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="@*" mode="mPers">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mPers"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:persName" mode="mPers">
        <xsl:copy>
            <!-- in case the tei:persName has been manually tagged and contains no child elements it should be split with an extra function -->
            <xsl:apply-templates select="@* | node()" mode="mPers"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:surname | tei:forename | tei:addName | tei:name" mode="mPers">
        <xsl:copy>
            <xsl:attribute name="sort" select="position()"/>
            <xsl:apply-templates select="@* | node()" mode="mPers"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:persName/text()[not(normalize-space(.)='')]" mode="mPers">
        <!--<xsl:message>
            <xsl:text>plain-text child: </xsl:text>
            <xsl:value-of select="."/>
        </xsl:message>-->
        <xsl:variable name="vTokenizedText">
            <xsl:call-template name="funcStringTokenize">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$vTokenizedText/tei:w">
            <!-- the rather unelegant text fields add whitespace necessary further down in the workflow -->
            <xsl:text> </xsl:text>
            <xsl:element name="tei:name">
                <xsl:value-of select="."/>
            </xsl:element>
            <xsl:text> </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>