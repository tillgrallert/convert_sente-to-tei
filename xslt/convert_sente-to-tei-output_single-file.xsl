<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

    <!-- this stylesheet produces a single TEI file containing biblStruct elements from a Sente XML -->

    <!-- to do: include facisimiles for the case of periodicals with one file per page as attachments -->

    <!-- v3a: using the Punch example from the Oxford summer school, I decided for a different organisation of multi-volume information -->
    <xsl:include href="templates_sente-to-tei.xsl"/>


    <!-- Correct structure for the autput, sorting of elements -->
    <xsl:template match="tss:references">
        <!-- this variable only works reliably for archival artifacts -->
        <!--<xsl:variable name="v_file-name-output"
                select="concat(tss:reference[1]//tss:characteristic[@name='Repository'],' ',replace(tss:reference[1]//tss:characteristic[@name='Signatur'],'/','-'),'uuid_',replace(tss:reference[1]//tss:characteristic[@name='UUID'],'-','_'))"
            />-->
        <xsl:variable name="v_uuid" select=".//tss:characteristic[@name = 'UUID']"/>
        <xsl:variable name="v_file-name-output" select="$v_uuid"/>
        <xsl:result-document href="_output/{$v_file-name-output}.TEIP5.xml">
            <xsl:element name="tei:TEI">
                <xsl:call-template name="templTeiHeader"/>
                <!-- tFacsimile necessitates the use of mGlobal further down the line -->
                <xsl:call-template name="t_facsimile"/>
                <!-- at the moment this only works for archival material -->
                <xsl:element name="tei:text">
                    <xsl:element name="tei:group">
                        <xsl:apply-templates select="./tss:reference">
                            <!-- here one could select all sort of sorting criteria -->
                            <!-- <xsl:sort select=".//tss:date[@type='Publication']"/> -->
                            <!-- <xsl:sort select="./tss:author"/> -->
                            <xsl:sort select=".//tss:characteristic[@name = 'publicationTitle']"/>
                            <xsl:sort select=".//tss:characteristic[@name = 'volume']"/>
                        </xsl:apply-templates>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="tss:reference">
        <xsl:element name="tei:text">
            <xsl:call-template name="templXmlId"/>
            <xsl:call-template name="templType"/>
            <xsl:element name="tei:front">
                <xsl:element name="tei:div">
                    <xsl:call-template name="t_biblStruct">
                        <xsl:with-param name="p_input" select="."/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tei:body">
                <xsl:call-template name="templAbstract"/>
                <xsl:element name="tei:div">
                    <xsl:attribute name="type">text</xsl:attribute>
                    <xsl:apply-templates select=".//tss:attachmentReference" mode="mGlobal"/>
                </xsl:element>
                <xsl:apply-templates select=".//tss:keywords" mode="mTEI"/>
                <xsl:apply-templates select=".//tss:notes" mode="mOrig"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="templTeiHeader">
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
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
