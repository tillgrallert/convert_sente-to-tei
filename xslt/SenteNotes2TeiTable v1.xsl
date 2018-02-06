<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    >
    
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:table">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <tei:row>
                <xsl:for-each select="./tei:row[1]/tei:cell">
                    <tei:cell>
                        <xsl:apply-templates select="@*"/>
                        <xsl:variable name="vNo" select="@n"/>
                        <xsl:value-of select="count(ancestor::tei:table//tei:cell[@n=$vNo][.='x'])"/>
                    </tei:cell>
                </xsl:for-each>
            </tei:row>
        </xsl:copy>
    </xsl:template>
    
<!--    <xsl:template match="tei:row[@role='data']">
        <xsl:variable name="v1">
            <xsl:for-each select="./tei:cell">
                <!-\- find all first values of 'x'  -\->
                <xsl:if test=".='x' and following-sibling::tei:cell[1][not(.='x')]">
                    <!-\-<xsl:value-of select="count(following-sibling::tei:cell[.='x'])"/>-\->
                    <tei:cell><xsl:value-of select="count(preceding-sibling::tei:cell[.='x']) -
                        count(preceding-sibling::item[not(.='x')]) +1"/>
                    </tei:cell>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="v2">
            <xsl:for-each select="$v1/tei:cell">
                <xsl:choose>
                    <xsl:when test="position()=1">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select=". - preceding-sibling::node()[1]"/></xsl:otherwise>
                </xsl:choose>
                <xsl:text>,</xsl:text>
            </xsl:for-each>
            
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <!-\-<tei:cell>
                <xsl:value-of select=" max(tokenize($v2,','))"/>
            </tei:cell>-\->
        </xsl:copy>
    </xsl:template>-->
    
    
<!--    <xsl:template match="tei:div[@type='table']">
        <xsl:variable name="vNames">
            <xsl:for-each-group select=".//tei:persName" group-by="normalize-space(.)">
                <xsl:sort select="." collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <tei:persName><xsl:value-of select="current-grouping-key()"/></tei:persName>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="vColumns">
            <xsl:for-each select="./tei:div">
                <tei:div>
                    <xsl:apply-templates select="@* | node()"/>
                </tei:div>
            </xsl:for-each>
            
        </xsl:variable>
        
        <tei:table>
            <tei:row role='label'>
                <tei:cell><xsl:text>Name</xsl:text></tei:cell>
                <xsl:for-each select="$vColumns/tei:div">
                    <tei:cell><xsl:apply-templates select="./tei:note" mode="mPages"/></tei:cell>
                </xsl:for-each>
            </tei:row>
            
            <!-\- data rows -\->
            <xsl:for-each select="$vNames/tei:persName">
                <xsl:variable name="vName" select="."/>
                <tei:row role='data'>
                    <tei:cell n="1"><xsl:value-of select="."/></tei:cell>
                <xsl:for-each select="$vColumns/tei:div">
                    <tei:cell>
                        <xsl:choose>
                            <xsl:when test=".//tei:persName=$vName">
                                <xsl:text>x</xsl:text>
                            </xsl:when>
                            <!-\-<xsl:when test="contains(.,$vName)">
                                <xsl:text>x</xsl:text>
                            </xsl:when>-\->
                        </xsl:choose>
                    </tei:cell>
                </xsl:for-each>
                </tei:row>
            </xsl:for-each>
        
        </tei:table>
        
    </xsl:template>
    <xsl:template match="tei:note" mode="mPages">
        <tei:date>
            <xsl:value-of select="concat(substring-before(substring-after(.,', '),']'),']')"/>
        </tei:date>
        <tei:note type='SenteCitationID'>
            <xsl:attribute name="corresp">
                <xsl:value-of select="@corresp"/>
                <xsl:text>@</xsl:text>
                <xsl:value-of select="following-sibling::tei:p[last()]"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </tei:note>
    </xsl:template>
    
<!-\-    <xsl:template match="tei:div[@type='table']/tei:div">
        <tei:div>
            <xsl:apply-templates select="@* | node()"/>
        </tei:div>
    </xsl:template>-\->
   
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>-->
    
    
    
    <!--<xsl:template match="tss:library">
        <tei:div>
            <xsl:apply-templates select=".//tss:reference"/>
        </tei:div>
        
    </xsl:template>
    
    <xsl:template match="tss:reference">
        <tei:div>
                    <tei:note>
                        <xsl:attribute name="type" select="'SenteCitationID'"/>
                        <xsl:attribute name="corresp">
                            <xsl:value-of select=".//tss:characteristic[@name='Citation identifier']"/>
                        </xsl:attribute>
                        <xsl:call-template name="funcCitation">
                            <xsl:with-param name="pRef" select="."/>
                        </xsl:call-template>
                    </tei:note>
            <tei:p>
                <xsl:apply-templates select=".//tss:note"/>
            </tei:p>
                    
        </tei:div>
    </xsl:template>
    
    <xsl:template match="tss:note">
        <xsl:if test="contains(lower-case(./tss:title),'municipalit')">
            <xsl:copy-of select="."/>
            
        </xsl:if>
    </xsl:template>-->
    
</xsl:stylesheet>