<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:variable name="vSearch" select="'AE'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select=".//tss:reference"/>
        
    </xsl:template>
    
    <xsl:template match="tss:references">
        <xsl:variable name="vAbbr">
            <xsl:for-each select="./tss:reference">
                <tei:choose>
                    <tei:abbr>
                        <xsl:value-of select="./tss:characteristics/tss:characteristic[@name='Repository']"/>
                    </tei:abbr>
                    <tei:expan>
                        <xsl:value-of select="./tss:characteristics/tss:characteristic[@name='Standort']"/>
                    </tei:expan>
                </tei:choose>
            </xsl:for-each>
        </xsl:variable>
        <tei:div>
        <xsl:for-each-group select="$vAbbr/tei:choose" group-by=".">
            <xsl:sort select="."/>
            <!--<xsl:copy-of select="."/>-->
            <xsl:text>#</xsl:text>
            <xsl:value-of select="./tei:abbr"/><xsl:text>   </xsl:text><xsl:value-of select="./tei:expan"/>
        </xsl:for-each-group>
        </tei:div>
    </xsl:template>
   
    
    <xsl:template match="tss:reference">
        <xsl:if test="./tss:characteristics/tss:characteristic[@name='Repository']=$vSearch">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>