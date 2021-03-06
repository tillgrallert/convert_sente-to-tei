<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

    <!-- this stylesheet produces a Tei XML file containig a listPers with all contributors and recipients in a Sente XML as unique values -->
    <!-- When the stylesheet is run on a Sente XML it produces and saves a TEI XML master file of unique persNames (checked against a master file) through modes m2 and m3 -->
    
    <!-- v4: split into two stylesheets: "Sente2Tei persName v4" and "TeiPersNameOperations v1"-->
    <!-- When the stylesheet is run on a TEI XML, mNym1 produces a nym file of unique values for surnames and forenames -->
    <!-- modes:
    - m2: produces a listPers for all contributors. supplies each name with an xml-id with the pattern 'p000000'.
    - m3: produces a listPers for all <persName> tags in the Sente Xml
    - pg mRep1: reproduces a TEI file
    - pg mRep2: links the persNames in a TEI file to a master Nym file and otherwise reproduces the TEI file
    - pg mNym1: produces the nym file from the Sente XML
    - mX: was used to clean up a TEI containing titles in the foreName tag.
    -->

    <!-- plans: 
        - currently the forename still contains a string of multiple names. These should be split into multiple forename tags
        - almost all names ending of ī etc. or commencing with al-, should be considered surnames
        - normalize-space !!!!    
-->

    <!-- v3: cleaned up mRep  -->
    <!-- v2b: cosmetic changes -->
    <!-- v2a: 
        - pgMode introduced for selecting the modes mRep strict (mRep1), mRep with alink to pgNyms through mNym (mRep2), or mNym1
        - entered the names of the new master files -->
    <!-- v2
        - included references to titles, honorific addresses etc. in the nym file 
        - check the nymfile for existing values and omit them from the results of mNym1. The resulting nyms carry xml-ids that can be added to the master nymfile
        - check for existing persNames in the pgPers in m2 and m3 and omit them from the results.
        - PROBLEM : Somehow m3 doesn't work with the current master file /BachUni/projekte/XML/TEI XML/master files/persNamesTempTEI 130313b.xml
    -->
    <!-- v2 planned: 
        - clean up the code for "Mardam Bek"
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

    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>
    <xsl:variable name="vDateCurrent" select="format-date(current-date(),'[Y01][M01][D01]')"/>
    <xsl:param name="pgNyms"
        select="document('/BachUni/projekte/XML/TEI XML/master files/NymMasterTEI.xml')"/>
    <xsl:param name="pgPers"
        select="document('/BachUni/projekte/XML/TEI XML/master files/PersNamesMasterTEI.xml')"/>
    <!-- persNamesTempTEI 130313b.xml -->
    <!-- this parameter toggles between the modes mRep1, mRep2, and mNym1 -->
    <xsl:param name="pgModes" select="'mNym1'"/>
    <xsl:param name="pTitles">
        <xsl:copy-of select="$pgNyms//tei:listNym[@type='title']"/>
    </xsl:param>
    <xsl:param name="pHonorific">
        <xsl:copy-of select="$pgNyms//tei:listNym[@type='honorific']"/>
    </xsl:param>
    <xsl:param name="pRanks">
        <xsl:copy-of select="$pgNyms//tei:listNym[@type='rank']"/>
    </xsl:param>
    <xsl:param name="pNameExclude">
        <tei:persName>ʿAbd</tei:persName>
        <tei:persName>Abdel</tei:persName>
        <tei:persName>Abdul</tei:persName>
        <tei:persName>Abū</tei:persName>
        <tei:persName>Abou</tei:persName>
        <tei:persName>Abī</tei:persName>
        <tei:persName>Bahāʾ</tei:persName>
        <tei:persName>Muḥī</tei:persName>
        <tei:persName>Shams</tei:persName>
    </xsl:param>
    <xsl:param name="pNameCanon">
        <tei:persName>
            <tei:surname>Mardam Bek</tei:surname>
        </tei:persName>
        <tei:persName>
            <tei:surname>Tuqī al-Dīn</tei:surname>
        </tei:persName>
    </xsl:param>

    <!-- templates dealing with Sente XML files -->
    <xsl:template match="tss:senteContainer">
        <xsl:result-document href="persNamesTempTEI {$vDateCurrent}.xml">
            <xsl:element name="tei:TEI">
                <xsl:element name="tei:teiHeader">
                    <xsl:element name="tei:fileDesc">
                        <xsl:element name="tei:titleStmt">
                            <xsl:element name="tei:title">Title</xsl:element>
                        </xsl:element>
                        <xsl:element name="tei:publicationStmt">
                            <xsl:element name="tei:p">Version of <xsl:value-of
                                    select="format-date(current-date(),'[D01] [MNn] [Y0001]')"
                                /></xsl:element>
                        </xsl:element>
                        <xsl:element name="tei:sourceDesc">
                            <xsl:apply-templates select="./tss:library" mode="m2"/>
                            <xsl:apply-templates select="./tss:library" mode="m3"/>
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

    <!-- mX: clean up a TEI file containing 'Miss' as tei:forename -->
    <xsl:template match="tei:TEI" mode="mX">
        <xsl:apply-templates mode="mX"/>
    </xsl:template>
    <xsl:template match="tei:persName" mode="mX">
        <xsl:choose>
            <xsl:when test="./*">
                <xsl:element name="tei:persName">
                    <xsl:apply-templates mode="mX"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:surname" mode="mX">
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
    <xsl:template match="tei:addName" mode="mX">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- templates dealing with TEI files -->
    <!-- toggle between mRep1, mRep2, and mNym1 -->
    <xsl:template match="tei:TEI">
        <xsl:if test="$pgModes='mRep1' or 'mRep2'">
            <xsl:result-document href="TempTEImRep {$vDateCurrent}.xml">
                <xsl:element name="tei:TEI">
                    <xsl:apply-templates mode="mRep"/>
                </xsl:element>
            </xsl:result-document>
        </xsl:if>
        <xsl:if test="$pgModes='mNym1'">
            <xsl:result-document href="NymTempTEI {$vDateCurrent}.xml">
                <xsl:element name="tei:TEI">
                    <xsl:apply-templates mode="mNym1"/>
                </xsl:element>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

    <!-- mRep -->
    <xsl:template match="*" mode="mRep">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="mRep"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*" mode="mRep">
        <xsl:copy>
            <xsl:apply-templates mode="mRep"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:persName" mode="mRep">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mRep"/>
            <!-- toggle between mRep and mNym. the latter creates links back to the nym file -->
            <xsl:if test="$pgModes='mRep1'">
                <xsl:apply-templates mode="mRep"/>
            </xsl:if>
            <xsl:if test="$pgModes='mRep2'">
                <xsl:apply-templates mode="mNym"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- changed in v3 -->
    <xsl:template match="tei:listNym" mode="mRep">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mRep"/>
            <xsl:for-each select="child::node()">
                <!-- sort nyms alphabetically based on ar-ijmes -->
                <xsl:sort
                    select="if (substring(if(./tei:form[@xml:lang='ar-ijmes']) then(./tei:form[@xml:lang='ar-ijmes'][1]) else(./tei:form[1]),1,3)='al-') then (substring(if(./tei:form[@xml:lang='ar-ijmes']) then(./tei:form[@xml:lang='ar-ijmes'][1]) else(./tei:form[1]),4)) else (substring(if(./tei:form[@xml:lang='ar-ijmes']) then(./tei:form[@xml:lang='ar-ijmes'][1]) else(./tei:form[1]),1))"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:choose>
                    <xsl:when test="self::tei:nym">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="mRep"/>
                            <xsl:for-each select="./tei:form">
                                <xsl:sort
                                    select="if(substring(.,1,3)='al-') then(substring(.,4)) else(.)"
                                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                                <xsl:copy>
                                    <xsl:apply-templates select="@* | node()" mode="mRep"/>
                                </xsl:copy>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="self::tei:listNym">
                        <xsl:copy>
                            <xsl:apply-templates select="@* | node()" mode="mRep"/>
                        </xsl:copy>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>


    <!-- mNym1: this produces the two listNyms of forenames and surnames -->
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

    <!-- mNym: links surnames and forenames to the pgNyms file via a @nymRef -->
    <xsl:template match="tei:surname" mode="mNym">
        <xsl:variable name="vName" select="."/>
        <xsl:copy>
        <xsl:if test=".!=''">
                <xsl:if test="$pgNyms//tei:listNym[@type='surname']//tei:form[.=$vName]">
                    <xsl:attribute name="nymRef">
                        <xsl:for-each
                            select="$pgNyms//tei:listNym[@type='surname']//tei:form[.=$vName]">
                            <xsl:value-of select="'#'"/>
                            <xsl:value-of select="parent::node()/@xml:id"/>
                        </xsl:for-each>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="mRep"/>
        </xsl:if>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:forename" mode="mNym">
        <xsl:variable name="vName1" select="."/>
        <xsl:if test=".!=''">
            <xsl:variable name="vNames" select="tokenize($vName1,' ','i')"/>
            <xsl:for-each select="$vNames">
                <xsl:variable name="vName2" select="."/>
                <xsl:element name="tei:forename">
                    <xsl:if test="$pgNyms//tei:listNym[@type='forename']//tei:form[.=$vName2]">
                        <xsl:attribute name="nymRef">
                            <xsl:for-each
                                select="$pgNyms//tei:listNym[@type='forename']//tei:form[.=$vName2]">
                                <xsl:value-of select="'#'"/>
                                <xsl:value-of select="parent::node()/@xml:id"/>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="sort">
                        <xsl:value-of select="position()"/>
                    </xsl:attribute>
                    <xsl:if test="$vName1/@type">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$vName1/@type"/>
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
    <!--<xsl:template match="tei:addName" mode="mNym">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="mRep"/>
        </xsl:copy>
    </xsl:template>-->
    
    <xsl:template match="tei:addName" mode="mNym">
        <xsl:variable name="vName" select="."/>
        <xsl:variable name="vType" select="@type"/>
        <xsl:if test=".!=''">
            <xsl:copy>
                <xsl:attribute name="type" select="$vType"/>
                <xsl:if test="$pgNyms//tei:listNym[@type=$vType]//tei:form[.=$vName]">
                    <xsl:attribute name="nymRef">
                        <xsl:for-each select="$pgNyms//tei:listNym[@type=$vType]//tei:form[.=$vName]">
                            <xsl:value-of select="'#'"/>
                            <xsl:value-of select="parent::node()/@xml:id"/>
                        </xsl:for-each>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="mRep"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <!--<xsl:template match="tei:addName[@type='honorific']" mode="mNym">
        <xsl:variable name="vName" select="."/>
        <xsl:if test=".!=''">
            <xsl:copy>
                <xsl:attribute name="type" select="@type"/>
                <xsl:if test="$pgNyms//tei:listNym[@type='honorific']//tei:form[.=$vName]">
                    <xsl:attribute name="nymRef">
                        <xsl:for-each select="$pgNyms//tei:listNym[@type='honorific']//tei:form[.=$vName]">
                            <xsl:value-of select="'#'"/>
                            <xsl:value-of select="parent::node()/@xml:id"/>
                        </xsl:for-each>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="mRep"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:addName[@type='rank']" mode="mNym">
        <xsl:variable name="vName" select="."/>
        <xsl:if test=".!=''">
            <xsl:copy>
                <xsl:attribute name="type" select="@type"/>
                <xsl:if test="$pgNyms//tei:listNym[@type='rank']//tei:form[.=$vName]">
                    <xsl:attribute name="nymRef">
                        <xsl:for-each select="$pgNyms//tei:listNym[@type='rank']//tei:form[.=$vName]">
                            <xsl:value-of select="'#'"/>
                            <xsl:value-of select="parent::node()/@xml:id"/>
                        </xsl:for-each>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="mRep"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>-->

    <xsl:variable name="vPerson2">
        <xsl:variable name="vNCountBase">
            <xsl:for-each select="$vPerson//tei:person">
                <xsl:sort select="./@xml:id"/>
                <xsl:if test="position()=last()">
                    <xsl:value-of select="substring-after(./@xml:id,'p')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vPersNamesUnique">
            <xsl:for-each-group select="$vPersons2/tei:persName" group-by=".">
                <xsl:if
                    test="current-grouping-key()[not(.=$vPerson//tei:persName[@type='simple'])][not(.=$pgPers//tei:listPerson[@type='mark-up']/tei:person/tei:persName[@type='simple'])]">
                    <xsl:element name="tei:persName">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:element name="tei:listPerson">
            <xsl:attribute name="type">mark-up</xsl:attribute>
            <xsl:for-each select="$vPersNamesUnique/tei:persName">
                <xsl:sort select="."
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:variable name="vNCount">
                    <xsl:number level="any"/>
                </xsl:variable>
                <!-- v2b: changed to regular expression tokenize($vStringClean,concat('(^|\W)',$vPersName,'($|\W)'),'i') -->
                <xsl:variable name="vPersNameParts" select="tokenize(normalize-space(.),' ','i')"/>
                <xsl:if
                    test=".[not(.=$vPerson//tei:persName[@type='simple'])][not(.=$pgPers//tei:listPerson[@type='mark-up']/tei:person/tei:persName[@type='simple'])]">
                    <xsl:element name="tei:person">
                        <xsl:attribute name="xml:id"
                            select="format-number($vNCountBase+$vNCount,'p000000')"/>
                        <xsl:element name="tei:persName">
                            <xsl:element name="tei:surname">
                                <xsl:choose>
                                    <xsl:when test="contains(.,'Mardam Bek')">
                                        <xsl:text>Mardam Bek</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="count($vPersNameParts)=2">
                                            <xsl:call-template name="tPersNamesSplit2">
                                                <xsl:with-param name="pInputString" select="$vPersNameParts"/>
                                                <xsl:with-param name="pOutput" select="'surname'"/>
                                            </xsl:call-template>
                                           <!-- <!-\- testing for Murād al-Qudsī and Miss Dixon -\->
                                            <xsl:if
                                                test="$vPersNameParts[2][not(.=$pTitles//tei:form)]">
                                                <xsl:if
                                                  test="$vPersNameParts[1][not(.=$pNameExclude/child::node())]">
                                                  <xsl:value-of select="$vPersNameParts[2]"/>
                                                </xsl:if>
                                            </xsl:if>-->
                                        </xsl:if>
                                        <xsl:if test="count($vPersNameParts)=3">
                                            <!-- testing for Murād Efendi al-Qudsī -->
                                            <xsl:if
                                                test="$vPersNameParts[2][(.=$pTitles//tei:form)]">
                                                <xsl:value-of select="$vPersNameParts[3]"/>
                                            </xsl:if>
                                            <!-- testing for Dr. Jacques Hoffmann doesn't work as Dr. Ibrāhīm Bey would not provide a surname -->
                                        </xsl:if>
                                        <xsl:if test="$vPersNameParts[last()]='zade'">
                                            <!--<xsl:attribute name="sort" select="position()[$vPersNameParts[last()]] -1"/>-->
                                            <xsl:value-of
                                                select="if($vPersNameParts[last()-1][not(.=$pTitles//tei:form)]) then($vPersNameParts[last()-1]) else($vPersNameParts[last()-2])"
                                            />
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                            <xsl:element name="tei:forename">
                                <!--<xsl:attribute name="sort">1</xsl:attribute>-->
                                <xsl:if test="count($vPersNameParts)=2">
                                    <!-- if any of the two names is part of the titles, honorifics, ranks, the other must be the personal name -->
                                    <xsl:call-template name="tPersNamesSplit2">
                                        <xsl:with-param name="pInputString" select="$vPersNameParts"/>
                                        <xsl:with-param name="pOutput" select="'forename'"/>
                                    </xsl:call-template>
                                    <!--<!-\- testing for Murād al-Qudsī -\->
                                    <xsl:if test="$vPersNameParts[2][not(.=$pTitles//tei:form)]">
                                        <xsl:choose>
                                            <!-\- testing for Murād al-Qudsī -\->
                                            <xsl:when test="$vPersNameParts[1][not(.=$pNameExclude/child::node())][not(.=$pHonorific//tei:form)]">
                                                <xsl:value-of select="$vPersNameParts[1]"/>
                                            </xsl:when>
                                            <!-\- testing for Miss Brown -\->
                                            <xsl:when test="$vPersNameParts[1][not(.=$pNameExclude/child::node())][(.=$pHonorific//tei:form)]"/>
                                            <!-\-<!-\- testing for Dr Brown -\->
                                            <xsl:when test="$vPersNameParts[1][not(.=$pNameExclude/child::node())][(.=$pTitles//tei:form)]"/>-\->
                                            <!-\- testing for Bishop Brown -\->
                                            <xsl:when test="$vPersNameParts[1][not(.=$pNameExclude/child::node())][(.=$pRanks//tei:form)]"/>
                                            <xsl:otherwise>
                                                <xsl:value-of select="."/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                    <!-\- testing for Murād Efendi -\->
                                    <xsl:if test="$vPersNameParts[2][(.=$pTitles//tei:form)]">
                                        <xsl:value-of select="$vPersNameParts[1]"/>
                                    </xsl:if>-->
                                </xsl:if>
                                <xsl:if test="count($vPersNameParts)=3">
                                    
                                    <xsl:choose>
                                        <!-- testing for ʿAbd al-Qādir Efendi -->
                                        <xsl:when test="$vPersNameParts[1][(.=$pNameExclude/child::node())]">
                                            <xsl:attribute name="sort" select="1"/>
                                            <xsl:value-of
                                                select="concat($vPersNameParts[1],' ',$vPersNameParts[2])"/>
                                        </xsl:when>
                                        <!-- testing for Dr. Jacques Hoffmann -->
                                        <xsl:when test="$vPersNameParts[1][(.=$pHonorific//tei:form)]">
                                            <xsl:attribute name="sort" select="2"/>
                                            <xsl:value-of select="$vPersNameParts[2]"/>
                                        </xsl:when>
                                        <!-- testing for Murād Efendi al-Qudsī -->
                                        <xsl:when test="$vPersNameParts[2][(.=$pTitles//tei:form)]">
                                            <xsl:attribute name="sort" select="1"/>
                                            <xsl:value-of select="$vPersNameParts[1]"/>
                                        </xsl:when>
                                        <!-- testing for Murād Qudsī Efendi -->
                                        <xsl:when test="$vPersNameParts[3][(.=$pTitles//tei:form)]">
                                            <xsl:attribute name="sort" select="1"/>
                                            <xsl:value-of
                                                select="concat($vPersNameParts[1],' ',$vPersNameParts[2])"
                                            />
                                        </xsl:when>
                                        
                                    </xsl:choose>
                                    
                                </xsl:if>
                                <!-- testing for Murād Efendi Qudsī zade -->
                                <xsl:if test="count($vPersNameParts)=4">
                                    <xsl:if test="$vPersNameParts[4]='zade'">
                                        <xsl:attribute name="sort" select="1"/>
                                        <xsl:choose>
                                            <xsl:when test="$vPersNameParts[2][(.=$pTitles//tei:form)]">
                                            <xsl:value-of select="$vPersNameParts[1]"/>
                                        </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                    select="concat($vPersNameParts[1],' ',$vPersNameParts[2])"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:element>
                            <!-- check for parts of names other than personal and family names -->
                            <xsl:for-each select="$vPersNameParts">
                                <xsl:if test=".=$pTitles//tei:form">
                                    <xsl:element name="tei:addName">
                                        <xsl:attribute name="type">title</xsl:attribute>
                                        <xsl:attribute name="sort" select="position()"/>
                                        <xsl:value-of select="."/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test=".=$pHonorific//tei:form">
                                    <xsl:element name="tei:addName">
                                        <xsl:attribute name="type">honorific</xsl:attribute>
                                        <xsl:attribute name="sort" select="position()"/>
                                        <xsl:value-of select="."/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test=".=$pRanks//tei:form">
                                    <xsl:element name="tei:addName">
                                        <xsl:attribute name="type">rank</xsl:attribute>
                                        <xsl:attribute name="sort" select="position()"/>
                                        <xsl:value-of select="."/>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                        <xsl:element name="tei:persName">
                            <xsl:attribute name="type">simple</xsl:attribute>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:variable>

    <xsl:variable name="vPersons2">
        <xsl:for-each
            select="if(contains(.,'&lt;/persName&gt;')) then(tokenize(., '&lt;/persName&gt;')) else()">
            <xsl:element name="tei:persName">
                <xsl:value-of
                    select="if(substring(substring-after(., '&lt;persName&gt;'),1,1)=' ') then(substring(substring-after(., '&lt;persName&gt;'),2)) else(substring-after(., '&lt;persName&gt;'))"
                />
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="vPersons">
        <xsl:element name="tei:listPerson">
            <xsl:for-each-group select=".//tss:author"
                group-by="concat(./tss:surname,./tss:fornames)">
                <xsl:sort
                    select="if (substring(./tss:surname,1,3)='al-') then (substring(./tss:surname,4)) else (substring(./tss:surname,1))"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:sort
                    select="if (substring(./tss:forenames,1,3)='al-') then (substring(./tss:forenames,4)) else (substring(./tss:forenames,1))"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
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
                <xsl:sort select="current-grouping-key()"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
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

    <!-- vPerson compiles a list of contributors from the tss:author entries -->
    <xsl:variable name="vPerson">
        <!-- vNCount establishes the highest xml:id in the PersNamesMasterTEI -->
        <xsl:variable name="vNCount">
            <xsl:for-each select="$pgPers//tei:listPerson//tei:person">
                <xsl:sort select="./@xml:id"/>
                <xsl:if test="position()=last()">
                    <xsl:value-of select="substring-after(./@xml:id,'p')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:element name="tei:listPerson">
            <xsl:attribute name="type">contributors</xsl:attribute>
            <xsl:for-each-group select="$vPersons//person"
                group-by="if (.//forname[1]!='') then (concat(.//surname,.//forname[1])) else (./persName)">
                <!-- concat(.//surname,.//forname[1]) -->
                <xsl:sort
                    select="if (substring(.//surname,1,3)='al-') then (substring(.//surname,4)) else (substring(.//surname,1))"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <xsl:sort
                    select="if (substring(.//forename[1],1,3)='al-') then (substring(.//forename[1],4)) else (substring(.//forename[1],1))"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
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

                <!-- check whether the person already exists in the pgPers -->
                <xsl:if
                    test="$vSimpleName[not(.=$pgPers//tei:listPerson[@type='contributors']/tei:person/tei:persName[@type='simple'])]">
                    <xsl:element name="tei:person">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="format-number($vNCount+position(),'p000000')"/>
                        </xsl:attribute>
                        <xsl:element name="tei:persName">
                            <xsl:element name="tei:surname">
                                <xsl:if test="$vSurnameParts[last()][not(.=$pTitles//tei:form)]">
                                    <xsl:value-of select="$vSurname"/>
                                </xsl:if>
                            </xsl:element>
                            <xsl:element name="tei:forename">
                                <xsl:attribute name="sort">1</xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="$vForenameParts[last()][.=$pTitles//tei:form]">
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
                                <xsl:if test="$vSurnameParts[last()][.=$pTitles//tei:form]">
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
                                <xsl:if test=".=$pTitles//tei:form">
                                    <xsl:element name="tei:addName">
                                        <xsl:attribute name="type">title</xsl:attribute>
                                        <xsl:attribute name="sort" select="position()"/>
                                        <xsl:value-of select="."/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test=".=$pHonorific//tei:form">
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
                </xsl:if>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:variable>

    <!-- this variable creates a list of unique surname values as nyms and checks whether they already exist in the nymfile -->
    <xsl:variable name="vNymSurname">
        <!-- this variable tries to establish the nym with the highest xml:id -->
        <xsl:variable name="vNymCount">
            <xsl:for-each select="$pgNyms//tei:listNym[@type='surname']/tei:nym">
                <xsl:sort select="./@xml:id"/>
                <xsl:if test="position()=last()">
                    <xsl:value-of select="substring-after(./@xml:id,'nymS')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each-group select="tei:TEI//tei:sourceDesc//tei:surname" group-by=".">
            <xsl:sort
                select="if (substring(.,1,3)='al-') then (substring(.,4)) else (substring(.,1))"
                collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:variable name="vSurname" select="current-grouping-key()"/>
            <!-- check whether the value is alreary present in pgNym -->
            <xsl:if test="$vSurname[not(.=$pgNyms//tei:listNym[@type='surname']//tei:form)]">
                <xsl:element name="tei:nym">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="format-number($vNymCount+position(),'nymS000000')"/>
                    </xsl:attribute>
                    <xsl:element name="tei:form">
                        <xsl:attribute name="xml:lang">ar-ijmes</xsl:attribute>
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="substring($vSurname,1,3)='al-'">
                                    <xsl:value-of select="'long'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'short'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$vSurname"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:for-each-group>


    </xsl:variable>

    <!-- this variable creates a list of unique forename values as nyms -->
    <xsl:variable name="vNymForename">
        <xsl:for-each-group select="tei:TEI//tei:sourceDesc//tei:forename" group-by=".">
            <xsl:sort
                select="if (substring(.,1,3)='al-') then (substring(.,4)) else (substring(.,1))"
                collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
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

    <!-- this variable creates a list of unique forename values as nyms and checks whether they already exist in the nymfile -->
    <xsl:variable name="vNymForename1">
        <xsl:variable name="vNymCount">
            <xsl:for-each select="$pgNyms//tei:listNym[@type='forename']/tei:nym">
                <xsl:sort select="./@xml:id"/>
                <xsl:if test="position()=last()">
                    <xsl:value-of select="substring-after(./@xml:id,'nymF')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each-group select="$vNymForename2//tei:form" group-by=".">
            <xsl:sort
                select="if (substring(.,1,3)='al-') then (substring(.,4)) else (substring(.,1))"
                collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
            <xsl:variable name="vForename" select="current-grouping-key()"/>
            <!-- check whether the value is alreary present in pgNym -->
            <xsl:if test="$vForename[not(.=$pgNyms//tei:listNym[@type='forename']//tei:form)]">
                <xsl:element name="tei:nym">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="format-number($vNymCount+position(),'nymF000000')"/>
                    </xsl:attribute>
                    <xsl:element name="tei:form">
                        <xsl:attribute name="xml:lang">ar-ijmes</xsl:attribute>
                        <xsl:value-of select="$vForename"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:template name="tPersNamesSplit2">
        <xsl:param name="pInputString"/>
        <!-- values: forename, surname -->
        <xsl:param name="pOutput"/>
        <xsl:for-each select="$pInputString">
            <xsl:choose>
                <xsl:when test=".[not(.=$pNameExclude/child::node())][.=$pHonorific//tei:form]"/>
                <xsl:when test=".[not(.=$pNameExclude/child::node())][.=$pTitles//tei:form]"/>
                <xsl:when test=".[not(.=$pNameExclude/child::node())][.=$pRanks//tei:form]"/>
                <xsl:otherwise>
                    <!-- we asume that, if both parts are valid strings that the first is the forename -->
                    <xsl:choose>
                        <xsl:when test="$pOutput='forename'">
                            <xsl:if test="position()=1">
                                <xsl:attribute name="sort" select="position()"/>
                                <xsl:value-of select="."/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$pOutput='surname'">
                            <xsl:if test="position()=last()">
                                <xsl:attribute name="sort" select="position()"/>
                                <xsl:value-of select="."/>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>

                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
