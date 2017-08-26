<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- this stylesheet produces a Tei XML file containig a listPers with all contributors and recipients in a Sente XML as unique valies -->
    <!-- v1c: introduces xml-id for each person in m3, based on the relative position and starting with the last xml-id of m2 + 1 -->
    <!-- v1b: strips away spaces at the beginning of persName -->
    <!-- v1a: mode m2 produces a listPers for all contrributors, m3 for all <persName> tags in the Sente Xml.
    As the "HTML" tags are exported as &lt;persName&gt;, I could use the tokenize function -->
    
    <!-- modes:
    - m2: produces a listPers for all contrributors. supplies each name with an xml-id with the pattern 'p000000'.
    - m3: produces a listPers for all <persName> tags in the Sente Xml
    -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/replacement.xsl"/> <!-- provides replacement functions -->
    <xsl:include href="/BachUni/projekte/XML/Functions/sort-ijmes.xsl"/>
    <!-- this variable specifies the sort order according to the IJMES transliteration of Arabic --><!-- In order to ignore "al-" some substring replacement must be done, I suppose -->
    <xsl:variable name="vDateCurrent" select="format-date(current-date(),'[Y01][M01][D01]')"/>
    
    
 <xsl:template match="tss:senteContainer">
     <xsl:result-document href="persNamesTempTEI {$vDateCurrent}.xml">
         <xsl:element name="tei:TEI">
             <xsl:element name="tei:teiHeader">
                 <xsl:element name="tei:fileDesc">
                     <xsl:element name="tei:titleStmt">
                         <xsl:element name="tei:title">Title</xsl:element>
                     </xsl:element>
                     <xsl:element name="tei:publicationStmt">
                         <xsl:element name="tei:p">Version of <xsl:value-of select="format-date(current-date(),'[D01] [MNn] [Y0001]')"/></xsl:element>
                     </xsl:element>
                     <xsl:element name="tei:sourceDesc">
     <!-- <xsl:apply-templates select=".//tss:library" mode="m1"/> -->
     <xsl:apply-templates select=".//tss:library" mode="m2"/>
     <xsl:apply-templates select=".//tss:library" mode="m3"/>
                     </xsl:element>
                     
                 </xsl:element>
             </xsl:element>
             <xsl:element name="tei:text">
                 <xsl:element name="tei:body">
                     <xsl:element name="tei:p">
                         <xsl:text>empty</xsl:text>
                     </xsl:element>
                 </xsl:element>
             </xsl:element>
         </xsl:element>  
     </xsl:result-document>
 </xsl:template>
    
    <xsl:template match="tss:library" mode="m3">
        <xsl:copy-of select="$vPerson2"/>
    </xsl:template>
    
    <xsl:variable name="vPerson2">
        <xsl:element name="tei:listPerson">
        <xsl:for-each-group select="$vPersons2/tei:persName" group-by=".">
            <xsl:sort select="." collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:element name="tei:person">
                <xsl:copy-of select="."/>
            </xsl:element>
        </xsl:for-each-group>
        </xsl:element>
    </xsl:variable>
    
    <xsl:variable name="vPersons2">
        
        <xsl:for-each select="if(contains(.,'&lt;/persName&gt;')) then(tokenize(., '&lt;/persName&gt;')) else()">
            <xsl:element name="tei:persName">
                <xsl:attribute name="type">simple</xsl:attribute>
                <xsl:value-of select="if(substring(substring-after(., '&lt;persName&gt;'),1,1)=' ') then(substring(substring-after(., '&lt;persName&gt;'),2)) else(substring-after(., '&lt;persName&gt;'))"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    
 
 <xsl:template match="tss:library" mode="m2">
     <xsl:copy-of select="$vPerson"/>                
 </xsl:template>
    
    <xsl:variable name="vPersons">
        <xsl:element name="tei:listPerson">
            <xsl:for-each-group select=".//tss:author" group-by="concat(./tss:surname,./tss:fornames)">
                <xsl:sort select="if (substring(./tss:surname,1,3)='al-') then (substring(./tss:surname,4)) else (substring(./tss:surname,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:sort select="if (substring(./tss:forenames,1,3)='al-') then (substring(./tss:forenames,4)) else (substring(./tss:forenames,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:element name="tei:person">
                    <xsl:element name="tei:persName">
                        <xsl:element name="tei:surname">
                            <xsl:value-of select="./tss:surname"/>
                        </xsl:element>
                        <xsl:element name="tei:forename">
                            <xsl:attribute name="n">1</xsl:attribute>
                            <xsl:value-of select="./tss:forenames"/>
                        </xsl:element>
                        <xsl:element name="tei:forename">
                            <xsl:attribute name="type">initial</xsl:attribute>
                            <xsl:value-of select="./tss:initials"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each-group>
            <xsl:for-each-group select=".//tss:characteristic[@name='Recipient']" group-by=".">
                <xsl:sort select="current-grouping-key()" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:element name="tei:person">
                    <xsl:element name="tei:persName">
                        <xsl:element name="tei:surname">
                            <xsl:value-of select="current-grouping-key()"/>
                        </xsl:element>
                        <xsl:element name="tei:forename">
                            <xsl:attribute name="n">1</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="tei:forename">
                            <xsl:attribute name="type">initial</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:element>
        
    </xsl:variable>
    
    <xsl:variable name="vPerson">
        <xsl:element name="tei:listPerson">
            <xsl:for-each-group select="$vPersons//person" group-by="if (.//forname[1]!='') then (concat(.//surname,.//forname[1])) else (./persName)"> <!-- concat(.//surname,.//forname[1]) -->
            <xsl:sort select="if (substring(.//surname,1,3)='al-') then (substring(.//surname,4)) else (substring(.//surname,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:sort select="if (substring(.//forename[1],1,3)='al-') then (substring(.//forename[1],4)) else (substring(.//forename[1],1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:element name="tei:person">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="format-number(position(),'p000000')"></xsl:value-of>
                </xsl:attribute>
                <xsl:element name="tei:persName">
                    <xsl:element name="tei:surname">
                        <xsl:value-of select=".//surname"/>
                    </xsl:element>
                    <xsl:element name="tei:forename">
                        <xsl:attribute name="n">1</xsl:attribute>
                        <xsl:value-of select=".//forename[@n=1]"/>
                    </xsl:element>
                    <xsl:element name="tei:forename">
                        <xsl:attribute name="type">initial</xsl:attribute>
                        <xsl:value-of select=".//forename[@type='initial']"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tei:persName">
                    <xsl:attribute name="type">simple</xsl:attribute>
                    <xsl:value-of select="concat(.//forename[@n=1],' ')"/>
                    <xsl:value-of select=".//surname"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each-group>
        </xsl:element>
    </xsl:variable>

</xsl:stylesheet>