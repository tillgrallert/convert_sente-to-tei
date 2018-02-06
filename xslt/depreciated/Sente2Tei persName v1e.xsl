<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- this stylesheet produces a Tei XML file containig a listPers with all contributors and recipients in a Sente XML as unique valies -->
    <!-- v2 planned: 
        - clean up the code for "Mardam Bek"
        - add a mode to attach new values to the end of an existing master file.
       
        
    -->
    <!-- problem: sometimes "and &lt;persName&gt;" ends up in the simple persName -->
    <!-- v1e: after some reply on TEI-L, I replaced @n with @sort, as this is the purpose I use it for.
        - accounted for Mr., Mrs., Mlle., Khawāja, Dr.; used addName[@type='honorific'][@sort='1']
        - they still end up as forenames in addition to addName
        - produce listNym and references to the nyms through a reproduction of a TEI authority file
    -->
    <!-- v1d: introduced various means to guess surnames and forenames from persName strings in m3.
        - Efendi, Bey, Pasha, and Agha and their various spellings are encoded as addName[@type='title']. The relative position of these titles is encoded as addName[@type='title]/@sort
        - made decision to strip "zade" from surnames and provide it as addName[@type='honorific']
    -->
    <!-- v1d planned:
        - m3: If strings in non-Arabic speaking sources consist of two words (apart from the above particles), they should be considered forename and surname.
        - m3: If a string of two words ends with Efendi, Bey, Pasha or Agha, then the first word should be considered a forename
        - m3: If a string of three ends with Efendi etc. the remaining two words thould be checked for the rule above. If false and if the first word is not ʿAbd, then the first word should be considered the forename and the second the surname of the person
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
    - mRep: reproduces a TEI file
    - mNym: links the persNames in a TEI file to a master Nym file
    - mNym1: produces the nym file
    -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/replacement.xsl"/> <!-- provides replacement functions -->
    <xsl:include href="/BachUni/projekte/XML/Functions/sort-ijmes.xsl"/>
    <!-- this variable specifies the sort order according to the IJMES transliteration of Arabic --><!-- In order to ignore "al-" some substring replacement must be done, I suppose -->
    <xsl:variable name="vDateCurrent" select="format-date(current-date(),'[Y01][M01][D01]')"/>
    <xsl:param name="pgNyms" select="document('/BachUni/projekte/XML/TEI XML/master files/NymTempTEI 130313.xml')"/>
    
    <xsl:param name="pTitles">
        <tei:persName>Āghā</tei:persName>
        <tei:persName>Aga</tei:persName>
        <tei:persName>Āğā</tei:persName>
        <tei:persName>Effendi</tei:persName>
        <tei:persName>Efendi</tei:persName>
        <tei:persName>Bey</tei:persName>
        <tei:persName>Pasha</tei:persName>
        <tei:persName>Pascha</tei:persName>
        <tei:persName>Paşa</tei:persName>
    </xsl:param>
    <xsl:param name="pHonorific">
        <!-- all but "zade" occur at the beginning of names  -->
        <tei:persName>Amīr</tei:persName>
        <tei:persName>Emir</tei:persName>
        <tei:persName>Dr.</tei:persName>
        <tei:persName>Mr.</tei:persName>
        <tei:persName>Mrs.</tei:persName>
        <tei:persName>Miss</tei:persName>
        <tei:persName>Herr</tei:persName>
        <tei:persName>Frau</tei:persName>
        <tei:persName>Fräulein</tei:persName>
        <tei:persName>Frl.</tei:persName>
        <tei:persName>Mme</tei:persName>
        <tei:persName>Mlle</tei:persName>
        <tei:persName>Monsieur</tei:persName>
        <tei:persName>zade</tei:persName>
        <tei:persName>zadé</tei:persName>
        <tei:persName>Rabbi</tei:persName>
        <tei:persName>Rev</tei:persName>
        <tei:persName>Rev.</tei:persName>
        <tei:persName>Rev.d</tei:persName>
        <tei:persName>Shaykh</tei:persName>
        <tei:persName>Sheikh</tei:persName>
        <tei:persName>Sir</tei:persName>
    </xsl:param>
    <xsl:param name="pNameExclude">
        <tei:persName>ʿAbd</tei:persName>
        <tei:persName>Abū</tei:persName>
        <tei:persName>Abou</tei:persName>
        <tei:persName>Abī</tei:persName>
        <tei:persName>Bahāʾ</tei:persName>
        <tei:persName>Muḥī</tei:persName>
    </xsl:param>
    <xsl:param name="pNameCanon">
        <tei:persName><tei:surname>Mardam Bek</tei:surname></tei:persName>
        <tei:persName><tei:surname>Tuqī Dīn</tei:surname></tei:persName>
    </xsl:param>
    
    
    
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
    
    <xsl:template match="tss:library" mode="m2">
        <xsl:copy-of select="$vPerson"/>                
    </xsl:template>
    <xsl:template match="tss:library" mode="m3">
        <xsl:copy-of select="$vPerson2"/>
    </xsl:template>
    
    <xsl:template match="tei:TEI" mode="mX">
        <xsl:apply-templates  mode="mX"/>
    </xsl:template>
    <xsl:template match="tei:persName"  mode="mX">
        <xsl:choose>
            <xsl:when test="./*">
                <xsl:element name="tei:persName">
                    <xsl:apply-templates  mode="mX"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:surname"  mode="mX">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="tei:forename" mode="mX">
        <xsl:choose>
            <xsl:when test=".='Miss'">
                <xsl:element name="addName">
                    <xsl:attribute name="type">honorific</xsl:attribute>
                    <xsl:attribute name="sort">1</xsl:attribute>
                    <xsl:value-of select="'Miss'"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:addName"  mode="mX">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <xsl:variable name="vPerson2">
        <xsl:element name="tei:listPerson">
            <xsl:attribute name="type">mark-up</xsl:attribute>
        <xsl:for-each-group select="$vPersons2/tei:persName" group-by=".">
            <xsl:sort select="." collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:variable name="vPersName" select="current-grouping-key()"/>
            <xsl:variable name="vPersNameParts" select="tokenize($vPersName,' ')"/>
            <xsl:if test="$vPersName[not(.=$vPerson//tei:persName[@type='simple'])]">
            <xsl:element name="tei:person">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="format-number($vCountPerson+position(),'p000000')"/>
                </xsl:attribute>
                <xsl:element name="tei:persName">
                    <xsl:element name="tei:surname">
                        <xsl:choose>
                        <xsl:when test="contains($vPersName,'Mardam Bek')">
                            <xsl:text>Mardam Bek</xsl:text>
                        </xsl:when>
                            <xsl:otherwise>
                        <xsl:if test="count($vPersNameParts)=2">
                            <!-- testing for Murād al-Qudsī and Miss Dixon -->
                            <xsl:if test="$vPersNameParts[2][not(.=$pTitles/child::node())]">
                                <xsl:if test="$vPersNameParts[1][not(.=$pNameExclude/child::node())]">
                                    <xsl:value-of select="$vPersNameParts[2]"/>
                                </xsl:if>
                            </xsl:if>
                        </xsl:if>
                        <xsl:if test="count($vPersNameParts)=3">
                            <!-- testing for Murād Efendi al-Qudsī -->
                            <xsl:if test="$vPersNameParts[2][(.=$pTitles/child::node())]">
                                <xsl:value-of select="$vPersNameParts[3]"/>
                            </xsl:if>
                            <!-- testing for Dr. Jacques Hoffmann doesn't work as Dr. Ibrāhīm Bey would not provide a surname -->
                        </xsl:if>
                        <xsl:if test="$vPersNameParts[last()]='zade'">
                            <xsl:value-of select="if($vPersNameParts[last()-1][not(.=$pTitles/child::node())]) then($vPersNameParts[last()-1]) else($vPersNameParts[last()-2])"/>
                        </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:element name="tei:forename">
                        <xsl:attribute name="sort">1</xsl:attribute>
                        <xsl:if test="count($vPersNameParts)=2">
                            <!-- testing for Murād al-Qudsī -->
                            <xsl:if test="$vPersNameParts[2][not(.=$pTitles/child::node())]">
                                <xsl:choose>
                                    <!-- testing for Murād al-Qudsī -->
                                    <xsl:when test="$vPersNameParts[1][not(.=$pNameExclude/child::node())][not(.=$pHonorific/child::node())]">
                                        <xsl:value-of select="$vPersNameParts[1]"/>
                                    </xsl:when>
                                    <!-- testing for Miss Brown -->
                                    <xsl:when test="$vPersNameParts[1][not(.=$pNameExclude/child::node())][(.=$pHonorific/child::node())]"/>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vPersName"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                            <!-- testing for Murād Efendi -->
                            <xsl:if test="$vPersNameParts[2][(.=$pTitles/child::node())]">
                                <xsl:value-of select="$vPersNameParts[1]"/>
                            </xsl:if>
                        </xsl:if>
                        <xsl:if test="count($vPersNameParts)=3">
                            <!-- testing for Dr. Jacques Hoffmann -->
                            <xsl:if test="$vPersNameParts[1][(.=$pHonorific/child::node())]">
                                <xsl:value-of select="$vPersNameParts[2]"/>
                            </xsl:if>
                            <!-- testing for Murād Efendi al-Qudsī -->
                            <xsl:if test="$vPersNameParts[2][(.=$pTitles/child::node())]">
                                <xsl:value-of select="$vPersNameParts[1]"/>
                            </xsl:if>
                            <!-- testing for Murād Qudsī Efendi -->
                            <xsl:if test="$vPersNameParts[3][(.=$pTitles/child::node())]">
                                <xsl:value-of select="concat($vPersNameParts[1],' ',$vPersNameParts[2])"/>
                            </xsl:if>
                        </xsl:if>
                        <!-- testing for Murād Efendi Qudsī zade -->
                        <xsl:if test="count($vPersNameParts)=4">
                            <xsl:if test="$vPersNameParts[4]='zade'">
                                <xsl:if test="$vPersNameParts[2][(.=$pTitles/child::node())]">
                                    <xsl:value-of select="$vPersNameParts[1]"/>
                                </xsl:if>
                            </xsl:if>
                        </xsl:if>
                        <!-- testing for ʿAbd al-Qādir Efendi -->
                        <xsl:if test="$vPersNameParts[1][(.=$pNameExclude/child::node())]">
                            <xsl:value-of select="concat($vPersNameParts[1],' ',$vPersNameParts[2])"/>
                        </xsl:if>
                            
                    </xsl:element>
                    <xsl:for-each select="$vPersNameParts">
                        <xsl:if test=".=$pTitles/child::node()">
                            <xsl:element name="tei:addName">
                                <xsl:attribute name="type">title</xsl:attribute>
                                <xsl:attribute name="sort" select="position()"/>
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test=".=$pHonorific/child::node()">
                            <xsl:element name="tei:addName">
                                <xsl:attribute name="type">honorific</xsl:attribute>
                                <xsl:attribute name="sort" select="position()"/>
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
                <xsl:element name="tei:persName">
                    <xsl:attribute name="type">simple</xsl:attribute>
                    <xsl:value-of select="$vPersName"/>
                </xsl:element>
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
                            <xsl:attribute name="sort">1</xsl:attribute>
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
                            <xsl:attribute name="sort">1</xsl:attribute>
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
            <xsl:attribute name="type">contributors</xsl:attribute>
            <xsl:for-each-group select="$vPersons//person" group-by="if (.//forname[1]!='') then (concat(.//surname,.//forname[1])) else (./persName)"> <!-- concat(.//surname,.//forname[1]) -->
            <xsl:sort select="if (substring(.//surname,1,3)='al-') then (substring(.//surname,4)) else (substring(.//surname,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:sort select="if (substring(.//forename[1],1,3)='al-') then (substring(.//forename[1],4)) else (substring(.//forename[1],1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:variable name="vForename" select=".//forename[@sort='1']"/>
                <xsl:variable name="vSurname" select=".//surname"/>
                <xsl:variable name="vForenameParts" select="tokenize($vForename,' ')"/>
                <xsl:variable name="vSurnameParts" select="tokenize($vSurname,' ')"/>
                <xsl:variable name="vSimpleName">
                    <xsl:if test=".//forename!=''">
                        <xsl:value-of select="concat($vForename,' ')"/>
                    </xsl:if>
                    <xsl:value-of select="$vSurname"/>
                </xsl:variable>
                <xsl:variable name="vSimpleNameParts" select="tokenize($vSimpleName,' ')"/>
                
            <xsl:element name="tei:person">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="format-number(position(),'p000000')"/>
                </xsl:attribute>
                <xsl:element name="tei:persName">
                    <xsl:element name="tei:surname">
                        <xsl:if test="$vSurnameParts[last()][not(.=$pTitles/child::node())]">
                            <xsl:value-of select="$vSurname"/>
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="tei:forename">
                        <xsl:attribute name="sort">1</xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$vForenameParts[last()][.=$pTitles/child::node()]">
                                <xsl:for-each select="$vForenameParts[position()!=last()]">
                                    <xsl:value-of select="."/>
                                    <xsl:if test="position()!=last()">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$vForename"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$vSurnameParts[last()][.=$pTitles/child::node()]">
                            <xsl:if test="$vForename!=''">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:for-each select="$vSurnameParts[position()!=last()]">
                                <xsl:value-of select="."/>
                                <xsl:if test="position()!=last()">
                                    <xsl:text> </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="tei:forename">
                        <xsl:attribute name="type">initial</xsl:attribute>
                        <xsl:value-of select=".//forename[@type='initial']"/>
                    </xsl:element>
                    <xsl:for-each select="$vSimpleNameParts">
                        <xsl:if test=".=$pTitles/child::node()">
                            <xsl:element name="tei:addName">
                                <xsl:attribute name="type">title</xsl:attribute>
                                <xsl:attribute name="sort" select="position()"/>
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test=".=$pHonorific/child::node()">
                            <xsl:element name="tei:addName">
                                <xsl:attribute name="type">honorific</xsl:attribute>
                                <xsl:attribute name="sort" select="position()"/>
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
                <xsl:element name="tei:persName">
                    <xsl:attribute name="type">simple</xsl:attribute>
                    <xsl:value-of select="$vSimpleName"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each-group>
        </xsl:element>
    </xsl:variable>
    
    
    <xsl:variable name="vCountPerson">
        <xsl:value-of select="count($vPerson//person)"/>
    </xsl:variable>
    <xsl:variable name="vNymSurname">
            <xsl:for-each-group select="tei:TEI//tei:sourceDesc//surname" group-by=".">
            <xsl:sort select="if (substring(.,1,3)='al-') then (substring(.,4)) else (substring(.,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:element name="tei:nym">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="format-number(position(),'nymS000000')"/>
                </xsl:attribute>
                <xsl:element name="tei:form">
                    <xsl:attribute name="xml:lang">ar-ijmes</xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="substring(.,1,3)='al-'">
                                <xsl:value-of select="'long'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'short'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="current-grouping-key()"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each-group>
        </xsl:variable>
    <xsl:variable name="vNymForename">    
        <xsl:for-each-group select="tei:TEI//tei:sourceDesc//forename" group-by=".">
                <xsl:sort select="if (substring(.,1,3)='al-') then (substring(.,4)) else (substring(.,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:element name="tei:nym">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="format-number(position(),'nymF000000')"/>
                    </xsl:attribute>
                    <xsl:element name="tei:form">
                        <xsl:attribute name="xml:lang">ar-ijmes</xsl:attribute>
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:variable>
    <!-- this variable produces a nym for every substring of the forenames, i.e. "muḥī" "al-dīn" etc. -->
    <xsl:variable name="vNymForename2">
        <xsl:for-each select="$vNymForename/tei:nym/tei:form">
            <xsl:element name="tei:nym">
                <xsl:element name="tei:form">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:element>
            <xsl:if test="count(tokenize(.,' '))>=2">
            <xsl:for-each select="tokenize(.,' ')">
                <xsl:element name="tei:nym">
                <!-- <xsl:attribute name="xml:id">
                    <xsl:value-of select="format-number(position(),'nymF000000')"/>
                </xsl:attribute> -->
                <xsl:element name="tei:form">
                    <!-- <xsl:attribute name="xml:lang">ar-ijmes</xsl:attribute> -->
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:element>
            </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="vNymForename1">    
        <xsl:for-each-group select="$vNymForename2//tei:form" group-by=".">
            <xsl:sort select="if (substring(.,1,3)='al-') then (substring(.,4)) else (substring(.,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:element name="tei:nym">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="format-number(position(),'nymF000000')"/>
                </xsl:attribute>
                <xsl:element name="tei:form">
                    <xsl:attribute name="xml:lang">ar-ijmes</xsl:attribute>
                    <xsl:value-of select="current-grouping-key()"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each-group>
    </xsl:variable>
    
    
    <xsl:template match="tei:TEI">
        <xsl:element name="tei:TEI">
            <!-- toggle between mRep and mNym1 -->
            <xsl:apply-templates mode="mNym1"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:teiHeader" mode="mRep">
        <xsl:element name="tei:teiHeader">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:fileDesc" mode="mRep">
        <xsl:element name="tei:fileDesc">
            
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:titleStmt" mode="mRep">
        <xsl:element name="tei:titleStmt">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:title" mode="mRep">
        <xsl:element name="tei:title">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:publicationStmt" mode="mRep">
        <xsl:element name="tei:publicationStmt">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:sourceDesc" mode="mRep">    
        <xsl:element name="tei:sourceDesc">
            <xsl:apply-templates mode="mRep"/>
            
        </xsl:element>
    </xsl:template>
    <!-- this produces the two listNyms of forenames and surnames -->
    <xsl:template match="tei:sourceDesc" mode="mNym1">    
        <xsl:element name="tei:sourceDesc">
            <!-- <xsl:apply-templates mode="mNym"/> -->
            <xsl:element name="tei:listNym">
                <xsl:attribute name="type">surname</xsl:attribute>
                <xsl:copy-of select="$vNymSurname"/>
            </xsl:element>
            <xsl:element name="tei:listNym">
                <xsl:attribute name="type">forename</xsl:attribute>
                <!-- toggle between vNymForename and vNymForename1 -->
                <xsl:copy-of select="$vNymForename1"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:listPerson" mode="mRep">    
        <xsl:element name="tei:listPerson">
            <xsl:attribute name="type">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:person" mode="mRep">    
        <xsl:element name="tei:person">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="./@xml:id"/>
            </xsl:attribute>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:persName" mode="mRep">    
        <xsl:element name="tei:persName">
            <xsl:if test="@type">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:if>
            <!-- toggle between mRep and mNym. the latter creates links back to the nym file -->
            <xsl:apply-templates mode="mNym"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:surname" mode="mRep">
        <xsl:variable name="vName" select="."/>
        <xsl:if test=".!=''">
        <xsl:element name="tei:surname">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:surname" mode="mNym">
        <xsl:variable name="vName" select="."/>
        <xsl:if test=".!=''">
            <xsl:element name="tei:surname">
                <xsl:attribute name="nymRef">
                    
                    <xsl:for-each select="$pgNyms//tei:listNym[@type='surname']/tei:nym//tei:form[.=$vName]">
                        <xsl:value-of select="'#'"/>
                        <xsl:value-of select="parent::node()/@xml:id"/>
                    </xsl:for-each>
                </xsl:attribute>
                <xsl:apply-templates mode="mRep"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:forename" mode="mRep">
        <xsl:variable name="vName" select="."/>
        <xsl:if test=".!=''">
        <xsl:element name="tei:forename">
            <xsl:if test="@sort">
                <xsl:attribute name="sort">
                    <xsl:value-of select="@sort"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@type">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:forename" mode="mNym">
        <xsl:variable name="vName" select="."/>
        
        <xsl:if test=".!=''">
            <xsl:variable name="vNames" select="tokenize($vName,' ')"/>
            <xsl:for-each select="$vNames">
                <xsl:variable name="vName2" select="."/>
            <xsl:element name="tei:forename">
                <xsl:attribute name="nymRef">
                    
                    <xsl:for-each select="$pgNyms//tei:listNym[@type='forename']/tei:nym//tei:form[.=$vName2]">
                        <xsl:value-of select="'#'"/>
                        <xsl:value-of select="parent::node()/@xml:id"/>
                    </xsl:for-each>
                </xsl:attribute>
                <xsl:attribute name="sort">
                    <xsl:value-of select="position()"/>
                </xsl:attribute>
                <xsl:if test="$vName/@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="$vName/@type"/>
                    </xsl:attribute>
                </xsl:if> 
                <!-- <xsl:for-each select="$pgNyms//tei:listNym[@type='forename']/tei:nym//tei:form[.=$vName2]">
                    <xsl:value-of select="parent::node()//tei:form[@xml:lang='ar-ijmes']"/>
                </xsl:for-each> -->
                
                <xsl:value-of select="$vName2"/>
            </xsl:element>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:addName" mode="mRep">    
        <xsl:element name="tei:addName">
            <xsl:if test="@type">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@sort">
                <xsl:attribute name="sort">
                    <xsl:value-of select="@sort"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:addName" mode="mNym">    
        <xsl:element name="tei:addName">
            <xsl:if test="@type">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@sort">
                <xsl:attribute name="sort">
                    <xsl:value-of select="@sort"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:listNym" mode="mRep">    
        <xsl:element name="tei:listNym">
            <xsl:if test="./@type">
                <xsl:attribute name="type">
                <xsl:value-of select="./@type"/>
            </xsl:attribute></xsl:if>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:nym" mode="mRep">    
        <xsl:element name="tei:nym">
            <xsl:if test="./@type">
            <xsl:attribute name="type">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@xml:id">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="./@xml:id"/>
            </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:form" mode="mRep">    
        <xsl:element name="tei:form">
            <xsl:if test="./@type">
            <xsl:attribute name="type">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@xml:id">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="./@xml:id"/>
            </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@xml:lang">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="./@xml:lang"/>
            </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:p" mode="mRep">
        <xsl:element name="tei:p">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:div" mode="mRep">
        <xsl:element name="tei:div">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:text" mode="mRep">
        <xsl:element name="tei:text">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:body" mode="mRep">
        <xsl:element name="tei:body">
            <xsl:apply-templates mode="mRep"/>
        </xsl:element>
    </xsl:template>
    

</xsl:stylesheet>