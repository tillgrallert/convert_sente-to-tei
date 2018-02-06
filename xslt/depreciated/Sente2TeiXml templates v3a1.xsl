<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v2a.xsl"/>

    <!-- add @xml:lang -->
    <!-- constructing the individual biblStruct -->
    <xsl:template name="templBiblStruct">
        <xsl:element name="tei:biblStruct">
            <xsl:call-template name="templLang"/>
            <xsl:choose>
                <xsl:when
                    test=".//tss:publicationType[@name='Newspaper article'] or .//tss:publicationType[@name='Archival Periodical Article']">
                    <xsl:element name="tei:analytic">
                        <xsl:apply-templates select=".//tss:author[@role='Author']"/>
                        <xsl:apply-templates select=".//tss:characteristic[@name='articleTitle']"/>
                    </xsl:element>
                    <xsl:element name="tei:monogr">
                        <xsl:apply-templates select=".//tss:author[@role='Editor']"/>
                        <xsl:apply-templates
                            select=".//tss:characteristic[@name='publicationTitle']"/>
                        <xsl:call-template name="templImprint"/>
                    </xsl:element>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:element name="tei:monogr">
                        <xsl:apply-templates select=".//tss:author[@role='Author']"/>
                        <xsl:apply-templates select=".//tss:author[@role='Editor']"/>
                        <xsl:apply-templates select=".//tss:characteristic[@name='Recipient']"/>
                        <xsl:apply-templates
                            select=".//tss:characteristic[@name='publicationTitle']"/>
                        <xsl:apply-templates select=".//tss:characteristic[@name='articleTitle']"/>
                        <xsl:call-template name="templImprint"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="templId"/>
        </xsl:element>
    </xsl:template>


    <!-- Contributors to the source/reference -->
    <xsl:template match="tss:author[@role='Author']">
        <xsl:element name="tei:author">
            <xsl:element name="tei:surname">
                <xsl:value-of select="tss:surname"/>
            </xsl:element>
            <xsl:element name="tei:forename">
                <xsl:value-of select="tss:forenames"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tss:author[@role='Editor']">
        <xsl:element name="tei:editor">
            <xsl:element name="tei:surname">
                <xsl:value-of select="tss:surname"/>
            </xsl:element>
            <xsl:element name="tei:forename">
                <xsl:value-of select="tss:forenames"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Recipient -->
    <xsl:template match="tss:characteristic[@name='Recipient']">
        <xsl:element name="tei:respStmt">
            <xsl:element name="tei:resp">recipient</xsl:element>
            <xsl:element name="tei:persName">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- Imprint -->
    <xsl:template name="templImprint">
        <xsl:element name="tei:imprint">
            <xsl:apply-templates select=".//tss:characteristic[@name='publisher']"/>
            <xsl:apply-templates select=".//tss:characteristic[@name='publicationCountry']"/>
            <xsl:apply-templates
                select="ancestor-or-self::tss:reference//tss:date[@type='Publication']"/>
            <xsl:apply-templates select=".//tss:characteristic[@name='Date Hijri']"/>
            <xsl:apply-templates select=".//tss:characteristic[@name='Date Rumi']"/>
            <xsl:apply-templates select=".//tss:characteristic[@name='volume']"/>
            <xsl:apply-templates select=".//tss:characteristic[@name='issue']"/>
            <xsl:apply-templates select=".//tss:characteristic[@name='pages']"/>
        </xsl:element>
    </xsl:template>

    <!-- Publisher -->
    <xsl:template match="tss:characteristic[@name='publisher']">
        <xsl:element name="tei:publisher">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Place of publication -->
    <xsl:template match="tss:characteristic[@name='publicationCountry']">
        <xsl:element name="tei:pubPlace">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Pages -->
    <xsl:template match="tss:characteristic[@name='pages']">
        <xsl:element name="tei:biblScope">
            <xsl:attribute name="tei:type">pp</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Volume -->
    <xsl:template match="tss:characteristic[@name='volume']">
        <xsl:element name="biblScope">
            <xsl:attribute name="type">vol</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Issue -->
    <xsl:template match="tss:characteristic[@name='issue']">
        <xsl:element name="tei:biblScope">
            <xsl:attribute name="tei:type">issue</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Dates -->
    <xsl:template match="tss:date[@type='Publication']">
        <xsl:variable name="vDPubY">
            <xsl:value-of select=".//tss:date[@type='Publication']/@year"/>
        </xsl:variable>
        <xsl:variable name="vDPubM">
            <xsl:value-of
                select="format-number(if(.//tss:date[@type='Publication']/@month!='') then(.//tss:date[@type='Publication']/@month) else(1),'00')"
            />
        </xsl:variable>
        <xsl:variable name="vDPubD">
            <xsl:value-of
                select="format-number(if(.//tss:date[@type='Publication']/@day!='') then(.//tss:date[@type='Publication']/@day) else(1),'00')"
            />
        </xsl:variable>
        <xsl:variable name="vDate">
            <xsl:value-of select="concat($vDPubY,'-',$vDPubM,'-',$vDPubD)"/>
        </xsl:variable>
        <xsl:element name="date">
            <xsl:attribute name="calendar">Gregorian</xsl:attribute>
            <xsl:attribute name="when">
                <xsl:value-of select="$vDate"/>
            </xsl:attribute>
            <!-- human-readable output of the date is mandatory here -->
            <xsl:choose>
                <xsl:when test="string-length($vDate)=10">
                    <xsl:value-of
                        select="format-date($vDate,'[F,*-3], [D1] [MNn,*-3] [Y0001]','en','AD',())"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$vDate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Date Rumi']">
        <xsl:element name="date">
            <xsl:attribute name="type">Rumi</xsl:attribute>
            <xsl:attribute name="calendar">Julian</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Date Hijri']">
        <xsl:element name="date">
            <xsl:attribute name="type">Hijri</xsl:attribute>
            <xsl:attribute name="calendar">Islamic</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <!-- Titles -->
    <xsl:template match="tss:characteristic[@name='publicationTitle']">
        <xsl:element name="title">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='articleTitle']">
        <xsl:element name="title">
            <xsl:attribute name="level">a</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <!-- Abstract -->
    <xsl:template name="templAbstract">
        <xsl:element name="div">
            <xsl:attribute name="type">abstract</xsl:attribute>
            <xsl:element name="p">
                <!-- In order to preserve existing markup copy-of must be chosen -->
                <xsl:copy-of select=".//tss:characteristic[@name='abstractText']/node()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- IDs -->
    <xsl:template name="templXmlId">
        <xsl:attribute name="xml:id">
            <!-- xml:ids cannot start with a number! why? -->
            <xsl:value-of
                select="concat('uuid_', replace(.//tss:characteristic[@name='UUID'],'-','_'))"/>
            <!-- <xsl:text>uuid_</xsl:text>
            <xsl:call-template name="templReplaceString">
                <xsl:with-param name="pString" select=".//tss:characteristic[@name='UUID']"/>
                <xsl:with-param name="pFind" select="'-'"/>
                <xsl:with-param name="pReplace" select="'_'"/>
            </xsl:call-template> -->
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="templId">
        <xsl:call-template name="templSignatur"/>
        <xsl:if
            test=".//tss:publicationType[@name='Archival File'] or .//tss:publicationType[@name='Archival Letter'] or .//tss:publicationType[@name='Archival Material'] or .//tss:publicationType[@name='Archival Journal Entry']">
            <xsl:call-template name="templACM"/>
        </xsl:if>
        <xsl:apply-templates select=".//tss:characteristic[@name='BibTeX cite tag']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='Citation identifier']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='OCLCID']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='ISBN']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='RIS reference number']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name='UUID']"/>


    </xsl:template>

    <xsl:template match="tss:characteristic[@name='ISBN']">
        <xsl:element name="idno">
            <xsl:attribute name="type">ISBN</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='BibTeX cite tag']">
        <xsl:element name="idno">
            <xsl:attribute name="type">BibTex</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='RIS reference number']">
        <xsl:element name="idno">
            <xsl:attribute name="type">RIS</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='OCLCID']">
        <xsl:element name="idno">
            <xsl:attribute name="type">OCLCID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Sente UUID -->
    <xsl:template match="tss:characteristic[@name='UUID']">
        <xsl:element name="idno">
            <!-- Supposedly XML names cannot contain whitespaces, thus, Sente UUID should be named SenteUUID -->
            <xsl:attribute name="type">SenteUUID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Sente ID -->
    <xsl:template match="tss:characteristic[@name='Citation identifier']">
        <xsl:element name="idno">
            <xsl:attribute name="type">CitationID</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- Signatur -->
    <xsl:template name="templSignatur" match="tss:characteristic[@name='Signatur']">
        <xsl:choose>
            <!-- Check if the Signatur, which is a custom field, matches the call-number -->
            <xsl:when
                test="compare(*//tss:characteristic[@name='Signatur'],*//tss:characteristic[@name='call-num'])=0">
                <xsl:call-template name="templCallNum"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- If the reference has no call number this field will be filled with Signatur data -->
                    <xsl:when test="*//tss:characteristic[@name='call-num']">
                        <xsl:element name="idno">
                            <xsl:attribute name="type">Signatur</xsl:attribute>
                            <xsl:value-of select="*//tss:characteristic[@name='Signatur']"/>
                        </xsl:element>
                        <xsl:call-template name="templCallNum"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="idno">
                            <xsl:attribute name="type">callNumber</xsl:attribute>
                            <xsl:value-of select="*//tss:characteristic[@name='Signatur']"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Call Number -->
    <xsl:template name="templCallNum" match="tss:characteristic[@name='call-num']">
        <xsl:element name="idno">
            <xsl:attribute name="type">callNumber</xsl:attribute>
            <xsl:value-of select="*//tss:characteristic[@name='call-num']"/>
        </xsl:element>
    </xsl:template>

    <!-- construct an archival class mark structure -->
    <xsl:template name="templACM">
        <xsl:element name="idno">
            <xsl:attribute name="type">archival-class-mark</xsl:attribute>
            <xsl:value-of select=".//tss:characteristic[@name='Repository']"/>
            <xsl:if test=".//tss:characteristic[@name='Repository']">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select=".//tss:characteristic[@name='Signatur']"/>
            <xsl:if test=".//tss:characteristic[@name='publicationCountry']">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select=".//tss:characteristic[@name='publicationCountry']"/>
            <xsl:if test=".//tss:characteristic[@name='issue']">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select=".//tss:characteristic[@name='issue']"/>
        </xsl:element>
    </xsl:template>

    <!-- construct a citation for newspaper artciles -->
    <xsl:template name="templNA">
        <xsl:variable name="vDate">
            <xsl:apply-templates select=".//tss:date[@type='Publication']"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test=".//tss:characteristic[@name='Short Titel']">
                <xsl:value-of select=".//tss:characteristic[@name='Short Titel']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select=".//tss:charateristic[@name='publicationTitle']"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:value-of select=".//tss:characteristic[@name='volume']"/>

    </xsl:template>



    <!-- Publication Type -->
    <!-- this should go as an attribute on the reference's div -->
    <xsl:template name="templType">
        <xsl:attribute name="type">
            <xsl:value-of select="replace(.//tss:publicationType/@name,' ','-')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Notes -->
    <xsl:template match="tss:notes" mode="mOrig">
        <xsl:element name="div">
            <xsl:attribute name="type">notes</xsl:attribute>
            <xsl:for-each select=".//tss:note">
                <xsl:sort select="./tss:pages" data-type="text"/>
                <!-- the field contains mixed strings and page ranges-->
                <xsl:element name="div">
                    <xsl:attribute name="type">note</xsl:attribute>
                    <!-- I do not know whether @n must be unique -->
                    <xsl:attribute name="n">
                        <xsl:value-of select="./tss:pages"/>
                    </xsl:attribute>
                    <xsl:element name="head">
                        <xsl:value-of select=".//tss:title"/>
                    </xsl:element>
                    <xsl:element name="p">
                        <xsl:text>p.</xsl:text>
                        <xsl:value-of select=".//tss:pages"/>
                        <xsl:text>; </xsl:text>
                        <xsl:element name="quote">
                            <xsl:value-of select=".//tss:quotation"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="p">
                        <!-- @type is not allowed on p -->
                        <xsl:value-of select=".//tss:comment"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tss:note" mode="mTEI">
        <xsl:element name="div">
            <xsl:attribute name="type">note</xsl:attribute>
            <xsl:element name="pb">
                <xsl:attribute name="n">
                    <xsl:value-of select="./tss:pages"/>
                </xsl:attribute>
                <xsl:attribute name="facs">
                    <xsl:apply-templates select="ancestor::tss:reference//tss:attachments"/>
                </xsl:attribute>
            </xsl:element>

            <xsl:element name="head">
                <xsl:value-of select="./tss:title"/>
            </xsl:element>

            <xsl:element name="div">
                <xsl:attribute name="type">quote</xsl:attribute>
                <xsl:element name="p">
                    <xsl:value-of select="./tss:quotation"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="note">
                <xsl:value-of select="./tss:comment"/>
            </xsl:element>

        </xsl:element>
    </xsl:template>

    <!-- Keywords/Tags -->
    <!-- This transformation replicates the original Sente XML -->
    <xsl:template match="tss:keywords" mode="mOrig">
        <xsl:element name="div">
            <xsl:attribute name="type">tags</xsl:attribute>
            <xsl:element name="tss:keywords">
                <xsl:for-each select=".//tss:keyword">
                    <xsl:sort select="." data-type="text" order="ascending"/>
                    <xsl:element name="tss:keyword">
                        <!-- The assigner should be retained -->
                        <xsl:attribute name="assigner">
                            <xsl:value-of select="@assigner"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tss:keywords" mode="mTEI">
        <xsl:element name="div">
            <xsl:attribute name="type">tags</xsl:attribute>
            <xsl:for-each select=".//tss:keyword">
                <xsl:sort select="." data-type="text" order="ascending"/>
                <xsl:element name="p">
                    <!-- The assigner should be retained -->
                    <!-- <xsl:attribute name="resp">
                            <xsl:value-of select="@assigner"/>
                        </xsl:attribute> -->
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- Languages -->
    <!-- the @xml:lang elemnt in TEI must conform to BCP 47. 
        "ar" stands for Arabic language and "Arab" for Arabic script. Compounds can be formed with a dash. 
        Thus, Ottoman Turkish should be encoded as "tr-Arab"  -->
    <xsl:template name="templLang">
        <xsl:if test="lower-case(.//tss:characteristic[@name='language'])">
            <xsl:attribute name="xml:lang">
                <xsl:choose>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'arabic'">
                        <xsl:text>ar</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'french'">
                        <xsl:text>fr</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name='language']) = 'ottoman turkish'">
                        <xsl:text>tr-Arab</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'ottoman'">
                        <xsl:text>tr-Arab</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'turkish'">
                        <xsl:text>tr</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'english'">
                        <xsl:text>en</xsl:text>
                    </xsl:when>
                    <xsl:when test="lower-case(.//tss:characteristic[@name='language']) = 'german'">
                        <xsl:text>de</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Attachments -->
    <xsl:template match="tss:attachments">
        <xsl:variable name="vAttachment">
            <xsl:value-of
                select="ancestor::tss:reference//tss:attachments/tss:attachmentReference[position()=1]"
            />
        </xsl:variable>
        <xsl:attribute name="facs">
            <xsl:value-of select="$vAttachment"/>
        </xsl:attribute>
    </xsl:template>



    <!-- Still missing fields -->
    <xsl:template match="tss:characteristic[@name='affiliation']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">affiliation</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='publicationStatus']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">publicationStatus</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='status']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">status</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Othertype']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Othertype</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Date read']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Date read</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Repository']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Repository</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Standort']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Standort</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Series number']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Series number</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Short Title']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Short Title</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Medium consulted']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Medium consulted</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='URL']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">URL</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='Web data source']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Web data source</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>



</xsl:stylesheet>
