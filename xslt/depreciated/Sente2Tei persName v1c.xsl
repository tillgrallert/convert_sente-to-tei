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
    <!-- v2 planned: 
        - add a mode to attach new values to the end of an existing master file.
        - accound for Mr., Mrs., Mlle., Efendi, Bey, Pasha, Khawāja, Dr.
        - m3: If strings in non-Arabic speaking sources consist of two words (apart from the above particles), they should be considered forename and surname.
        - m3: If a string of two words ends with Efendi, Bey, Pasha or Agha, then the first word should be considered a forename
        - m3: If a string of three ends with Efendi etc. the remaining two words thould be checked for the rule above. If false and if the first word is not ʿAbd, then the first word should be considered the forename and the second the surname of the person
    -->
    <!-- v1d planned:
        
    -->
    <!-- v1c: introduces xml-id for each person in m3, based on the relative position and starting with the last xml-id of m2 + 1. For that purpose, vCountPerson counts the persons inside the listPerson of m2
        - done: m2 still produces a whitespace in front fo surnames in case of missing forename
        - done for m3: check wether persName[@type='simple'] is already present for any of the entries from m2, i.e. as $vPerson//tei:persName[@type='simple']. -->
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
    
    <xsl:param name="pStringExclude">
        <tei:persName>Āghā</tei:persName>
        <tei:persName>Aga</tei:persName>
        <tei:persName>Effendi</tei:persName>
        <tei:persName>Efendi</tei:persName>
        <tei:persName>Bey</tei:persName>
        <tei:persName>Pasha</tei:persName>
        <tei:persName>Pascha</tei:persName>
        <tei:persName>Paşa</tei:persName>
    </xsl:param>
    
    <xsl:variable name="vPerson2">
        <xsl:element name="tei:listPerson">
        <xsl:for-each-group select="$vPersons2/tei:persName" group-by=".">
            <xsl:sort select="." collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:variable name="vPersName" select="current-grouping-key()"/>
            <xsl:variable name="vPersNameParts" select="tokenize($vPersName,' ')"/>
            <xsl:if test="current-grouping-key()!=$vPerson//tei:persName[@type='simple']">
            <xsl:element name="tei:person">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="format-number($vCountPerson+position(),'p000000')"/>
                </xsl:attribute>
                <xsl:copy-of select="."/>
                <xsl:if test="count($vPersNameParts)=2">
                    <xsl:if test="$vPersNameParts[2][not(.=$pStringExclude/child::node())]">
                        <xsl:element name="tei:persName">
                            <xsl:element name="tei:surname">
                                <xsl:value-of select="$vPersNameParts[2]"/>
                            </xsl:element>
                            <xsl:element name="tei:forename">
                                <xsl:attribute name="n">1</xsl:attribute>
                                <xsl:value-of select="$vPersNameParts[1]"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="count($vPersNameParts)=3">
                    <xsl:if test="$vPersNameParts[2][(.=$pStringExclude/child::node())]">
                        <xsl:element name="tei:persName">
                            <xsl:element name="tei:surname">
                                <xsl:value-of select="$vPersNameParts[3]"/>
                            </xsl:element>
                            <xsl:element name="tei:forename">
                                <xsl:attribute name="n">1</xsl:attribute>
                                <xsl:value-of select="$vPersNameParts[1]"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
            </xsl:element>
            </xsl:if>
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
                    <xsl:value-of select="format-number(position(),'p000000')"/>
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
                    <xsl:if test=".//forename!=''">
                        <xsl:value-of select="concat(.//forename[@n=1],' ')"/>
                    </xsl:if>
                    <xsl:value-of select=".//surname"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each-group>
        </xsl:element>
    </xsl:variable>
    
    
    <xsl:variable name="vCountPerson">
        <xsl:value-of select="count($vPerson//person)"/>
    </xsl:variable>

</xsl:stylesheet>