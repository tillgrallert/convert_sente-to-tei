<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no" version="1.0"/>
    
    <!-- this stylesheet is work in progress. It is intended to convert Sente XML of periodicals and newspaper articles into TEI P5. -->
    <!-- plan:
        1. Group all references into different periodical titles using the publication type
            - Generate a <gi>tei:teiHeader</gi> for each periodical
        2. Group all periodicals into volumes or years
            - Generate bibliographic metadata for each volume
        2. Generate TEI files that group each issue of a periodical as <gi>tei:text</gi> inside a <gi>tei:group</gi>
            - Bibliographic metadata for each issue can be stored in <gi>tei:front</gi> -->

    <!--    <xsl:include href="../Functions/BachFunctions v3.xsl"/>-->
    <xsl:include href="Sente2TeiXml templates v3c.xsl"/>

    <!-- reproduce everything that is not covered in specialised templates -->
    <xsl:template match="@*  | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- this only deals with periodicals -->
    <!-- group references by title -->
    <xsl:template match="tss:references">
        <xsl:for-each-group group-by=".//tss:characteristic[@name='publicationTitle']"
            select="tss:reference[contains( lower-case(./tss:publicationType/@name),'periodical') or contains( lower-case(./tss:publicationType/@name),'newspaper')]">
            <xsl:sort select=".//tss:characteristic[@name='volume']"/>
            <xsl:sort select=".//tss:characteristic[@name='issue']"/>
            <xsl:variable name="vPubTitle"
                select="translate(translate(current-grouping-key(),$vIjmesDiac,$vIjmesNormal),':;.,/','')"/>
            <!-- group into volumes and generate a TEI file each -->
            <xsl:for-each-group group-by=".//tss:characteristic[@name='issue']"
                select="current-group()">
                <xsl:result-document href="output/{$vPubTitle}-{current-grouping-key()}.TEIP5.xml">
                    <xsl:element name="tei:TEI">
                        <xsl:element name="tei:teiHeader">
                            <xsl:element name="tei:fileDesc">
                                <xsl:element name="tei:titleStmt">
                                    <xsl:element name="tei:title">
                                        <xsl:attribute name="level" select="'m'"/>
                                        <xsl:value-of
                                            select=".//tss:characteristic[@name='publicationTitle']"
                                        />
                                    </xsl:element>
                                    <xsl:element name="tei:title">
                                        <xsl:attribute name="level" select="'m'"/>
                                        <xsl:attribute name="type" select="'sub'"/>
                                        <xsl:text>Electronic TEI edition</xsl:text>
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
                                    <xsl:element name="tei:biblStruct">
                                        <xsl:call-template name="templLang"/>
                                        <xsl:element name="tei:monogr">
                                            <xsl:apply-templates
                                                select=".//tss:author[@role='Editor']"/>
                                            <xsl:apply-templates
                                                select=".//tss:characteristic[@name='publicationTitle']"/>
                                            <xsl:element name="tei:imprint">
                                                <xsl:apply-templates
                                                  select=".//tss:characteristic[@name='publisher']"/>
                                                <xsl:apply-templates
                                                  select=".//tss:characteristic[@name='publicationCountry']"/>
                                                <xsl:apply-templates
                                                  select=".//tss:characteristic[@name='issue']"/>
                                                <xsl:element name="tei:date">
                                                    <xsl:attribute name="notBefore">
                                                        <xsl:value-of select="current-group()[1]/descendant::tss:date[@type='Publication']/@year"/>
                                                    </xsl:attribute>
                                                    <xsl:attribute name="notAfter">
                                                        <xsl:value-of select="current-group()[last()]/descendant::tss:date[@type='Publication']/@year"/>
                                                    </xsl:attribute>
                                                   <!--<xsl:attribute name="notAfter">
                                                        <xsl:call-template name="funcSenteNormalizeDate">
                                                            <xsl:with-param name="pInput"
                                                                select="current-group()[last()]/descendant::tss:date[@type='Publication']" as="node()"
                                                            />
                                                        </xsl:call-template>
                                                    </xsl:attribute>-->
                                                   <!-- <xsl:value-of select="current-group()[1]/descendant::tss:date[@type='Publication']/@year"/>
                                                    <xsl:text>-</xsl:text>
                                                    <xsl:value-of select="current-group()[last()]/descendant::tss:date[@type='Publication']/@year"/>-->
                                                </xsl:element>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                            <xsl:call-template name="tRevisionDesc"/>
                        </xsl:element>
                        <xsl:call-template name="tFacsimile"/>
                        <xsl:element name="tei:text">
                            <xsl:element name="tei:group">
                                <xsl:apply-templates select="current-group()"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:result-document>
            </xsl:for-each-group>

        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="tss:reference">
        <xsl:element name="tei:text">
            <xsl:attribute name="xml:id"
                select="concat('uuid_',.//tss:characteristic[@name='UUID'])"> </xsl:attribute>
            <xsl:element name="tei:front">
                <xsl:element name="tei:div">
                    <xsl:call-template name="templBiblStruct"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tei:body">
                <xsl:element name="tei:div">
                    <xsl:attribute name="type" select="'abstract'"/>
                    <xsl:element name="tei:p">
                        <xsl:value-of select=".//tss:characteristic[@name='abstractText']"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tei:div">
                    <xsl:attribute name="type" select="'notes'"/>
                    <xsl:apply-templates select="./tss:notes"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tei:back">
                <xsl:apply-templates mode="mTEI" select="./tss:keywords"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
