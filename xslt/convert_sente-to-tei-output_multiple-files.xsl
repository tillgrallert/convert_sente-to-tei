<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

    <!--   <xsl:include href="../Functions/BachFunctions v3.xsl"/>-->
    <xsl:include href="Sente2TeiXml%20templates%20v3c.xsl"/>

    <!-- this stylesheet produces a TEI P5 XML file for each reference found in a Sente XML file -->

    <!-- Problem: p cannot have a @type attribute -->
    <!-- Problem: sourceDesc cannot contain p if it contains any other child nodes -->
    <!-- Problem: any other contributor types but author and editor are note yet supported, e.g. "Translator" -->


    <!-- Correct structure for the autput, sorting of elements -->
    <xsl:template match="tss:reference">
        <xsl:variable name="vRef">
            <xsl:choose>
                <xsl:when test="contains(./tss:publicationType/@name,'Archival File')">
                    <xsl:call-template name="templACM"/>
                </xsl:when>
                <xsl:when test="contains(./tss:publicationType/@name,'Archival Letter')">
                    <xsl:call-template name="templACM"/>
                </xsl:when>
                <xsl:when test="contains(./tss:publicationType/@name,'Archival Material')">
                    <xsl:call-template name="templACM"/>
                </xsl:when>
                <xsl:when test="contains(./tss:publicationType/@name,'Newspaper')">
                    <xsl:call-template name="templNA"/>
                </xsl:when>
                <xsl:when test="contains(./tss:publicationType/@name,'Archival Periodical')">
                    <xsl:call-template name="templNA"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select=".//tss:author[1]/tss:surname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select=".//tss:date[@type='Publication']/@year"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vFileName"
            select="concat(replace($vRef,'/','-'),' uuid_',replace(.//tss:characteristic[@name='UUID'],'-','_'))"/>
        <xsl:result-document href="output/{$vFileName}.TEIP5.xml">
            <xsl:element name="tei:TEI">
                <xsl:element name="tei:teiHeader">
                    <xsl:element name="tei:fileDesc">
                        <xsl:element name="tei:titleStmt">
                            <xsl:element name="tei:title">
                                <!-- the current file name should be added here -->
                                <!--<xsl:value-of select="$vRef"/>-->
                                <xsl:call-template name="funcCitation">
                                    <xsl:with-param name="pRef" select="."/>
                                    <xsl:with-param name="pMode" select="'fn'"/>
                                    <xsl:with-param name="pOutputFormat" select="'tei'"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                        <xsl:call-template name="tEditionStmt"/>
                        <xsl:element name="tei:publicationStmt">
                            <xsl:element name="tei:p">
                                <xsl:text>This should be replaced with some description</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="tei:sourceDesc">
                            <!--<xsl:element name="p">
                             <xsl:value-of select=".//tss:publicationType/@name"/>
                         </xsl:element>-->
                            <xsl:call-template name="templBiblStruct"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:if test="contains(lower-case(./tss:publicationType/@name),'letter')">
                        <xsl:element name="profileDesc">
                            <xsl:call-template name="tCorrespDesc"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:call-template name="tRevisionDesc"/>
                </xsl:element>
                <xsl:call-template name="tFacsimile"/>
                <xsl:element name="tei:text">
                    <xsl:element name="tei:body">
                        <xsl:call-template name="templAbstract"/>
                        <xsl:element name="tei:div">
                            <xsl:attribute name="type">text</xsl:attribute>
                            <xsl:apply-templates select=".//tss:attachmentReference" mode="mGlobal"
                            />
                        </xsl:element>
                        <xsl:apply-templates select=".//tss:keywords" mode="mTEI"/>
                        <xsl:apply-templates select=".//tss:notes" mode="mOrig"/>
                        <!--<xsl:element name="div">
                            <xsl:attribute name="type">abstract</xsl:attribute>
                            <xsl:element name="p">
                                <xsl:value-of select=".//tss:characteristic[@name='abstractText']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="tei:div">
                            <xsl:attribute name="type">content</xsl:attribute>
                            <xsl:apply-templates select=".//tss:attachmentReference" mode="mGlobal"
                            />
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="type">notes</xsl:attribute>
                            <xsl:apply-templates select=".//tss:note" mode="mTEI"/>
                        </xsl:element>-->
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>


    <!--    <xsl:template match="tss:reference">  
     <xsl:element name="div">
        <xsl:call-template name="templXmlId"/>
        <xsl:call-template name="templType"/>
        <xsl:call-template name="templLang"/>
        <xsl:element name="biblStruct">
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
    </xsl:template> -->



</xsl:stylesheet>
