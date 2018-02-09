<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

    <!-- this stylesheet produces a single TEI file containing a single listBibl with biblStruct children from a Sente XML -->

    <!-- to do: 
        include facisimiles for the case of periodicals with one file per page as attachments
        find a way to keep URLs to digital representations
        a revisionDesc is needed -->
    <xsl:include href="templates_sente-to-tei.xsl"/>
    
    <xsl:param name="p_flip-volume-and-issue" select="true()"/>


    <!-- Correct structure for the autput, sorting of elements -->
    <xsl:template match="tss:references">
        <!-- this variable only works reliably for archival artifacts -->
        <xsl:variable name="vFileName">
            <xsl:value-of
                select="concat(tss:reference[1]//tss:characteristic[@name = 'Repository'], ' ', replace(tss:reference[1]//tss:characteristic[@name = 'Signatur'], '/', '-'), 'uuid_', replace(tss:reference[1]//tss:characteristic[@name = 'UUID'], '-', '_'))"
            />
        </xsl:variable>
        <xsl:result-document href="_output/{$vFileName}.TEIP5.xml">
            <xsl:element name="tei:TEI">
                <xsl:call-template name="t_teiHeader"/>
                <!-- tFacsimile necessitates the use of mGlobal further down the line -->
<!--                <xsl:call-template name="tFacsimile"/>-->
                <!-- at the moment this only works for archival material -->
                <xsl:element name="tei:text">
                    <xsl:element name="tei:body">
                        <xsl:element name="tei:listBibl">
                            <xsl:apply-templates select="tss:reference">
                                <!-- here one could select all sort of sorting criteria -->
                                <!-- <xsl:sort select=".//tss:date[@type='Publication']"/> -->
                                <!-- <xsl:sort select="./tss:author"/> -->
                                <xsl:sort select=".//tss:characteristic[@name = 'publicationTitle']"/>
                                <xsl:sort select=".//tss:characteristic[@name = 'volume']"/>
                            </xsl:apply-templates>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="tss:reference">
        <xsl:call-template name="t_biblStruct">
            <xsl:with-param name="p_input" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="t_teiHeader">
        <xsl:element name="tei:teiHeader">
            <xsl:element name="tei:fileDesc">
                <xsl:element name="tei:titleStmt">
                    <xsl:element name="tei:title">
                        <!-- the current file name should be added here -->
                        <xsl:value-of
                            select=".//tss:reference[1]//tss:characteristic[@name = 'Repository']"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of
                            select=".//tss:reference[1]//tss:characteristic[@name = 'Signatur']"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tei:publicationStmt">
                    <xsl:element name="tei:p">
                        <xsl:text>This should be replaced with some description</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tei:sourceDesc">
                    <xsl:element name="tei:p">
                        <xsl:value-of select=".//tss:reference[1]//tss:publicationType/@name"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:call-template name="t_revisionDesc"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
