<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- this stylesheet produces  -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/replacement.xsl"/> <!-- provides replacement functions -->
    <xsl:variable name="sortIjmes" select="'&lt; ʾ,ʿ &lt; a,A &lt; ā, Ā &lt; b,B &lt; c,C &lt; d,D &lt; ḍ, Ḍ &lt; e,é,E,É &lt; f,F &lt; g,G &lt; ġ, Ġ &lt; h,H &lt; ḥ, Ḥ &lt; ḫ, Ḫ &lt; i,I &lt; ī, Ī  &lt; j,J &lt; k,K &lt; ḳ, Ḳ &lt; l,L &lt; m,M &lt; n,N &lt; o,O &lt; p,P &lt; q,Q &lt; r,R &lt; s,S &lt; ṣ, Ṣ &lt; t,T &lt; ṭ, Ṭ &lt; ṯ, Ṯ &lt; u,U &lt; ū, Ū &lt; v,V &lt; w,W &lt; x,X &lt; y,Y &lt; z, Z &lt; ẓ, Ẓ'"/> <!-- this variable specifies the sort order according to the IJMES transliteration of Arabic -->
    <!-- In order to ignore "al-" some substring replacement must be done, I suppose -->
    <xsl:variable name="vDateCurrent" select="format-date(current-date(),'[Y01][M01][D01]')"/>
    
    
 <xsl:template match="tss:senteContainer">
     <!-- <xsl:apply-templates select=".//tss:library" mode="m1"/> -->
     <xsl:apply-templates select=".//tss:library" mode="m2"/>
 </xsl:template>
 <xsl:template match="tss:library" mode="m1">
     <xsl:result-document href="persNamesTemp.xml">
         <xsl:apply-templates select=".//tss:references" mode="m1">
         </xsl:apply-templates>
     </xsl:result-document>
 </xsl:template>
 
 <xsl:template match="tss:library" mode="m2">
     <xsl:result-document href="persNamesTempTEI {$vDateCurrent}.xml">
         <xsl:element name="tei:TEI">
             <xsl:element name="tei:teiHeader">
                 <xsl:element name="tei:fileDesc">
                     <xsl:element name="tei:titleStmt">
                         <xsl:element name="tei:title">Title</xsl:element>
                     </xsl:element>
                     <xsl:element name="tei:publicationStmt">
                         <xsl:element name="tei:p">Some publication statement</xsl:element>
                     </xsl:element>
                     <xsl:element name="tei:sourceDesc">
                         <!-- some templates to construct the person database -->
                         <xsl:copy-of select="$vPerson"/>
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
            </xsl:element>
        </xsl:for-each-group>
        </xsl:element>
    </xsl:variable>

    <!-- Correct structure for the autput, sorting of elements -->
 <xsl:template match="tss:references" mode="m1">
     <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
         <xsl:element name="teiHeader">
             <xsl:element name="fileDesc">
                 <xsl:element name="titleStmt">
                     <xsl:element name="title">Title</xsl:element>
                 </xsl:element>
                 <xsl:element name="publicationStmt">
                     <xsl:element name="p">Some publication statement</xsl:element>
                 </xsl:element>
                 <xsl:element name="sourceDesc">
                     <!-- some templates to construct the person database -->
                     <xsl:call-template name="templContributors"/>
                 </xsl:element>
             
             </xsl:element>
         </xsl:element>
         <xsl:element name="text">
             <xsl:element name="body">
                 <xsl:element name="p">
                     <xsl:text>empty</xsl:text>
                 </xsl:element>
             </xsl:element>
         </xsl:element>
     </xsl:element>
 </xsl:template>
 
 <xsl:template name="templContributors">
     <xsl:variable name="vAuthor">
         <xsl:for-each-group select=".//tss:author" group-by="concat(./tss:surname,./tss:fornames)">
             <xsl:sort select="if (substring(./tss:surname,1,3)='al-') then (substring(./tss:surname,4)) else (substring(./tss:surname,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
             <xsl:sort select="if (substring(./tss:forenames,1,3)='al-') then (substring(./tss:forenames,4)) else (substring(./tss:forenames,1))" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
             <xsl:element name="person">
                 <xsl:element name="persName">
                     <xsl:element name="surname">
                         <xsl:value-of select="./tss:surname"/>
                     </xsl:element>
                     <xsl:element name="forename">
                         <xsl:attribute name="n">1</xsl:attribute>
                         <xsl:value-of select="./tss:forenames"/>
                     </xsl:element>
                     <xsl:element name="forename">
                         <xsl:attribute name="type">initial</xsl:attribute>
                         <xsl:value-of select="./tss:initials"/>
                     </xsl:element>
                 </xsl:element>
             </xsl:element>
         </xsl:for-each-group>
     </xsl:variable>
     <xsl:variable name="vRecipient">
         <xsl:for-each-group select=".//tss:characteristic[@name='Recipient']" group-by=".">
             <xsl:sort select="current-grouping-key()" collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
             <xsl:element name="person">
                 <xsl:element name="persName">
                     <xsl:element name="surname">
                         <xsl:value-of select="current-grouping-key()"/>
                     </xsl:element>
                 </xsl:element>
             </xsl:element>
         </xsl:for-each-group>
     </xsl:variable>
     <xsl:variable name="vPerson">
         <xsl:element name="listPerson">
             <xsl:copy-of select="$vAuthor"/>
             <xsl:copy-of select="$vRecipient"/>
         </xsl:element>
     </xsl:variable>
     
     <xsl:copy-of select="$vPerson"/>
 </xsl:template>
 



</xsl:stylesheet>