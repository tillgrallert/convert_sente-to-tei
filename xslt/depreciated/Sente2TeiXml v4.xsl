<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- this stylesheet transforms references from SenteXML into biblStruct elements of a TEI P5 xml -->
    <!-- v4: re-integrated the "single file" and "multiple files" stylesheets, provided a param for selection of modes -->
    <!-- to be done: include the URL field and the URI to the attachments -->
    <!-- v3b: includes the URL as @facs of the biblStruct element -->
    
    
    <xsl:include href="Sente2TeiXml templates v3c.xsl"/>
    <xsl:param name="pMode" select="'single'"/>
    
    <xsl:template match="tss:senteContainer">
        <xsl:if test="$pMode='multiple'">
            <xsl:apply-templates mode="mMult"/>
        </xsl:if>
        <xsl:if test="$pMode='single'">
            <xsl:apply-templates mode="mSing"/>
        </xsl:if>
    </xsl:template>
    
    <!-- mMult: Correct structure for the autput, sorting of elements -->
    <xsl:template match="tss:reference" mode="mMult">
        <xsl:variable name="vRef">
            <xsl:choose>
                <xsl:when test="contains(./tss:publicationType/@name,'Archival')">
                    <xsl:call-template name="templACM"/>
                </xsl:when>
                <xsl:when test="contains(./tss:publicationType/@name,'Newspaper')">
                    <xsl:call-template name="templNA"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(.//tss:author[1]/tss:surname,' ',.//tss:date[@type='Publication']/@year)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vFileName" select="concat(replace($vRef,'/','-'),' uuid_',replace(.//tss:characteristic[@name='UUID'],'-','_'))"/>
        <xsl:result-document href="out/{$vFileName}.xml">
            <xsl:element name="TEI" >
                <xsl:element name="teiHeader">
                    <xsl:element name="fileDesc">
                        <xsl:element name="titleStmt">
                            <xsl:element name="title">
                                <!-- the current file name should be added here -->
                                <xsl:value-of select="$vRef"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="publicationStmt">
                            <xsl:element name="p">
                                <xsl:text>This should be replaced with some description</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="sourceDesc">
                            <!-- <xsl:element name="p">
                                <xsl:value-of select=".//tss:publicationType/@name"/>
                            </xsl:element> -->
                            <xsl:call-template name="templBiblStruct"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:call-template name="templRevisionDesc"/>
                </xsl:element>
                <xsl:element name="text">
                    <xsl:element name="body">
                        <xsl:element name="div">
                            <xsl:attribute name="type">abstract</xsl:attribute>
                            <xsl:element name="p">
                                <xsl:value-of select=".//tss:characteristic[@name='abstractText']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="type">content</xsl:attribute>
                            <xsl:apply-templates select=".//tss:note" mode="mTEI"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
    <!-- mSing: Correct structure for the autput, sorting of elements -->
    <xsl:template match="tss:references" mode="mSing">
        <xsl:variable name="vFileName" select="concat(.//tss:reference[1]//tss:characteristic[@name='Repository'],' ',replace(.//tss:reference[1]//tss:characteristic[@name='Signatur'],'/','-'))"/>
        <xsl:result-document href="out/{$vFileName}.xml">
            <xsl:element name="TEI">
                <!-- at the moment this only works for archival material -->
                <xsl:call-template name="templTeiHeader"/>
                <xsl:element name="text">
                    <xsl:element name="body">
                        <xsl:apply-templates select="./tss:reference" mode="mSing">
                            <!-- here one could select all sort of sorting criteria -->
                            <!-- <xsl:sort select=".//tss:date[@type='Publication']"/> -->
                            <!-- <xsl:sort select="./tss:author"/> -->
                            <xsl:sort select=".//tss:characteristic[@name='publicationTitle']"/>
                            <xsl:sort select=".//tss:characteristic[@name='volume']"/>
                        </xsl:apply-templates>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tss:reference" mode="mSing">  
        <xsl:element name="div">
            <xsl:call-template name="templXmlId"/>
            <xsl:call-template name="templType"/>
            <xsl:call-template name="templBiblStruct"/>
            
            <xsl:call-template name="templAbstract"/>
            <xsl:apply-templates select=".//tss:keywords" mode="mTEI"/>
            <xsl:apply-templates select=".//tss:notes" mode="mOrig"/>
            <xsl:element name="div">
                <xsl:for-each select=".//tss:attachmentReference">
                    <xsl:element name="div">
                        <xsl:attribute name="facs" select="./tss:URL"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
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
            <xsl:call-template name="templRevisionDesc"/>
        </xsl:element>
    </xsl:template>
    <xsl:template name="templRevisionDesc">
        <xsl:element name="revisionDesc">
            <xsl:element name="change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:text>File generated from Sente XML through automatic conversion.</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>