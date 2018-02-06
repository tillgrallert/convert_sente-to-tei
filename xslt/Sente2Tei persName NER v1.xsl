<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- This stylesheet takes Sente XML as input and checks the abstract field against a canonical list of nyms. It employs the template funcStringNER, which is linked through BachFunctions -->

    <!--<xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>-->
    <xsl:include href="../Functions/BachFunctions v3.xsl"/>
    <!-- moved pgNyms to BachFunctions -->
    <!--<xsl:param name="pgNyms"
        select="document('../TEI XML/master files/NymMasterTEI.xml')"/>-->
   
    <!--Identity transform for remaining-->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tss:characteristic[@name='abstractText']">
        <xsl:copy>
            <xsl:apply-templates select="@* "/>
                <xsl:call-template name="funcStringNER">
                    <xsl:with-param name="pInput" select="."/>
                    <xsl:with-param name="pNymFile" select="$pgNyms"/>
               </xsl:call-template>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
