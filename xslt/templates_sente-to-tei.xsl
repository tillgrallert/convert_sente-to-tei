<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:ct="http://wiki.tei-c.org/index.php/SIG:Correspondence/task-force-correspDesc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no" version="1.0"/>

    <!-- this stylesheet provides various templates for the conversion of SenteXML to TEI biblStruct elements -->

    <!-- to do: 
        include facisimiles for the case of periodicals with one file per page as attachments
        find a way to keep URLs to digital representations -->

    <xsl:include href="../../../xslt-functions/functions_core.xsl"/>

    <!-- date functions -->
    <!--    <xsl:include href="http://tillgrallert.github.io/xslt-calendar-conversion/functions/date-functions.xsl"/>-->
    <xsl:import href="../../../xslt-calendar-conversion/functions/date-functions.xsl"/>
    <!-- identify the author of the change by means of a @xml:id -->
    <!--    <xsl:param name="p_id-editor" select="'pers_TG'"/>-->
    <xsl:import href="../../../OpenArabicPE/oxygen-project/OpenArabicPE_parameters.xsl"/>
    <!--<xsl:include href="../../tss_tools/tss_core-functions.xsl"/>
    <xsl:include href="../../tss_tools/tss_citation-functions.xsl"/>-->

    <xsl:param name="p_flip-volume-and-issue" select="true()"/>

    <!-- add @xml:lang -->
    <!-- constructing the individual biblStruct -->
    <xsl:template name="t_biblStruct">
        <xsl:param name="p_input"/>
        <xsl:element name="biblStruct">
            <xsl:call-template name="templLang"/>
            <xsl:apply-templates select="tss:attachments" mode="m_att.facs"/>
            <xsl:choose>
                <xsl:when
                    test="$p_input//tss:publicationType[@name = 'Newspaper article'] or $p_input//tss:publicationType[@name = 'Archival Periodical Article']">
                    <xsl:element name="analytic">
                        <xsl:apply-templates select="$p_input//tss:author[@role = 'Author']"/>
                        <xsl:apply-templates
                            select="$p_input//tss:characteristic[@name = 'articleTitle']"/>
                    </xsl:element>
                    <xsl:element name="monogr">
                        <xsl:apply-templates select="$p_input//tss:author[@role = 'Editor']"/>
                        <xsl:apply-templates
                            select="$p_input//tss:characteristic[@name = 'publicationTitle']"/>
                        <xsl:call-template name="t_idno"/>
                        <xsl:call-template name="t_imprint">
                            <xsl:with-param name="p_input" select="$p_input"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:when>
                <!-- the proposal of the TEI Correspondence SIG for letters could be implemented here -->
                <!-- the SIG's proposals have been included in TEI P5 as part of profileDesc -->
                <!-- names should be looked up in reference files or internet authority files (GND, GeoNames, etc. ) -->
                <!--<xsl:when test="contains(lower-case(./tss:publicationType/@name),'letter')">
                    <xsl:element name="ct:correspDesc">
                        <xsl:for-each select="./tss:authors/tss:author[@role='Author']">
                            <xsl:element name="ct:sender">
                                <!-\-<xsl:apply-templates select="."/>-\->
                                <xsl:element name="persName">
                                    <xsl:element name="surname">
                                        <xsl:value-of select="./tss:surname"/>
                                    </xsl:element>
                                    <xsl:text>, </xsl:text>
                                    <xsl:element name="forename">
                                        <xsl:value-of select="./tss:forenames"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                        <xsl:element name="ct:Addressee">
                            <xsl:element name="persName">
                                <xsl:value-of select=".//tss:characteristic[@name='Recipient']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="ct:placeSender">
                            <xsl:element name="placeName">
                                <xsl:value-of
                                    select=".//tss:characteristic[@name='publicationCountry']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="ct:dateSender">
                            <xsl:apply-templates select=".//tss:date[@type='Publication']"/>
                        </xsl:element>
                        <!-\- unfortunately, Sente did not allow / I was not interested to record either the location of the recipient or the date of a letter's arrival -\->
                        <xsl:element name="ct:placeAddressee"/>
                        <xsl:element name="ct:dateAddressee"/>
                    </xsl:element>
                </xsl:when>-->

                <xsl:otherwise>
                    <xsl:element name="monogr">
                        <xsl:apply-templates select="$p_input//tss:author[@role = 'Author']"/>
                        <xsl:apply-templates select="$p_input//tss:author[@role = 'Editor']"/>
                        <xsl:apply-templates
                            select="$p_input//tss:characteristic[@name = 'Recipient']"/>
                        <xsl:apply-templates
                            select="$p_input//tss:characteristic[@name = 'publicationTitle']"/>
                        <xsl:apply-templates
                            select="$p_input//tss:characteristic[@name = 'articleTitle']"/>
                        <xsl:call-template name="t_idno"/>
                        <xsl:call-template name="t_imprint">
                            <xsl:with-param name="p_input" select="$p_input"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>


    <!-- Contributors to the source/reference -->
    <xsl:template match="tss:author[@role = 'Author']">
        <xsl:element name="author">
            <xsl:element name="surname">
                <xsl:value-of select="tss:surname"/>
            </xsl:element>
            <xsl:element name="forename">
                <xsl:value-of select="tss:forenames"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tss:author[@role = 'Editor']">
        <xsl:element name="editor">
            <xsl:element name="surname">
                <xsl:value-of select="tss:surname"/>
            </xsl:element>
            <xsl:element name="forename">
                <xsl:value-of select="tss:forenames"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Recipient -->
    <xsl:template match="tss:characteristic[@name = 'Recipient']">
        <xsl:element name="respStmt">
            <xsl:element name="resp">recipient</xsl:element>
            <xsl:element name="persName">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- Imprint -->
    <xsl:template name="t_imprint">
        <xsl:param name="p_input"/>
        <xsl:element name="imprint">
            <xsl:apply-templates select="$p_input//tss:characteristic[@name = 'publisher']"/>
            <xsl:apply-templates select="$p_input//tss:characteristic[@name = 'publicationCountry']"/>
            <xsl:apply-templates select="$p_input//tss:date[@type = 'Publication']"/>
            <xsl:apply-templates select="$p_input//tss:characteristic[@name = 'Date Hijri']"/>
            <xsl:apply-templates select="$p_input//tss:characteristic[@name = 'Date Rumi']"/>
            <xsl:apply-templates select="$p_input//tss:characteristic[@name = 'volume']"/>
            <xsl:apply-templates select="$p_input//tss:characteristic[@name = 'issue']"/>
            <xsl:apply-templates select="$p_input//tss:characteristic[@name = 'pages']"/>
        </xsl:element>
    </xsl:template>

    <!-- Publisher -->
    <xsl:template match="tss:characteristic[@name = 'publisher']">
        <xsl:element name="publisher">
            <xsl:element name="orgName">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- Place of publication -->
    <xsl:template match="tss:characteristic[@name = 'publicationCountry']">
        <xsl:element name="pubPlace">
            <xsl:element name="placeName">
                <xsl:apply-templates select="text()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- Pages -->
    <xsl:template match="tss:characteristic[@name = 'pages']">
        <xsl:element name="biblScope">
            <xsl:attribute name="unit" select="'page'"/>
            <!-- missing @from and @to -->
            <xsl:analyze-string select="." regex="(\d+)-(\d+)">
                <xsl:matching-substring>
                    <xsl:attribute name="from" select="regex-group(1)"/>
                    <xsl:attribute name="to" select="regex-group(2)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:attribute name="from" select="."/>
                    <xsl:attribute name="to" select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <!-- Volume -->
    <xsl:template match="tss:characteristic[@name = 'volume']">
        <xsl:element name="biblScope">
            <!-- due to Sente's limited file management capabilities, I usually inverted issue and volume information for newspaper articles
                contains(ancestor::tss:reference/tss:publicationType/@name,'Periodical') or -->
            <xsl:choose>
                <xsl:when test="$p_flip-volume-and-issue = true()">
                    <xsl:choose>
                        <xsl:when
                            test="contains(ancestor::tss:reference/tss:publicationType/@name, 'Periodical') or contains(ancestor::tss:reference/tss:publicationType/@name, 'Newspaper')">
                            <xsl:attribute name="unit" select="'issue'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="unit" select="'volume'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="unit" select="'volume'"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- missing @from and @to -->
            <xsl:attribute name="from" select="."/>
            <xsl:attribute name="to" select="."/>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <!-- Issue -->
    <xsl:template match="tss:characteristic[@name = 'issue']">
        <xsl:element name="biblScope">
            <!-- due to Sente's limited file management capabilities, I usually inverted issue and volume information for newspaper articles 
                contains(ancestor::tss:reference/tss:publicationType/@name,'Periodical') or -->
            <xsl:choose>
                <xsl:when test="$p_flip-volume-and-issue = true()">
                    <xsl:choose>
                        <xsl:when
                            test="contains(ancestor::tss:reference/tss:publicationType/@name, 'Periodical') or contains(ancestor::tss:reference/tss:publicationType/@name, 'Newspaper')">
                            <xsl:attribute name="unit" select="'volume'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="unit" select="'issue'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="unit" select="'issue'"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- missing @from and @to -->
            <xsl:attribute name="from" select="."/>
            <xsl:attribute name="to" select="."/>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <!-- Dates -->
    <xsl:template match="tss:date[@type = 'Publication']">
        <xsl:variable name="vDPubY" select="@year"/>
        <xsl:variable name="vDPubM" select="format-number(number(@month), '00')"/>
        <xsl:variable name="vDPubD" select="format-number(number(@day), '00')"/>
        <xsl:variable name="vDate">
            <xsl:value-of select="concat($vDPubY, '-', $vDPubM, '-', $vDPubD)"/>
        </xsl:variable>
        <xsl:element name="date">
            <!-- the Gregorian norm must not be recorded -->
            <!--<xsl:attribute name="calendar">Gregorian</xsl:attribute>-->
            <!-- human-readable output of the date is mandatory here -->
            <!-- v3c: check whether $vDate is a valid xs:date -->
            <xsl:choose>
                <xsl:when test="$vDate castable as xs:date">
                    <xsl:attribute name="when">
                        <xsl:value-of select="$vDate"/>
                    </xsl:attribute>
                    <xsl:value-of select="format-date($vDate, '[D1] [MNn,*-3] [Y0001]')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="substring($vDate, 5, 6) = '-02-29'">
                            <xsl:attribute name="when">
                                <xsl:value-of select="concat($vDPubY, '-03-01')"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat('29 Feb ', $vDPubY)"/>
                        </xsl:when>
                        <xsl:when test="$vDPubM != '' and $vDPubD = ''">
                            <xsl:attribute name="when" select="$vDPubY"/>
                            <xsl:attribute name="notBefore"
                                select="concat($vDPubY, '-', $vDPubM, '-01')"/>
                            <!--<xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pMonth" select="$vDPubM"/>
                                <xsl:with-param name="pLang" select="'GEn'"/>
                                <xsl:with-param name="pMode" select="'name'"/>
                            </xsl:call-template>-->
                            <xsl:value-of
                                select="oape:date-convert-months($vDPubM, 'name', '', '#cal_gregorian')"/>
                            <xsl:value-of select="concat(' ', $vDPubY)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="when" select="$vDPubY"/>
                            <xsl:value-of select="$vDPubY"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        <!-- for Ḥadīqat al-Akhbār: add julian dates -->
        <xsl:if test="$vDate castable as xs:date">
            <!--<xsl:variable name="v_date-julian">
                <xsl:call-template name="funcDateG2J">
                    <xsl:with-param name="pDateG" select="$vDate"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:element name="date">
                <xsl:attribute name="calendar" select="'#cal_julian'"/>
                <xsl:attribute name="datingMethod" select="'#cal_julian'"/>
                <xsl:attribute name="when" select="$vDate"/>
                <xsl:attribute name="when-custom" select="$v_date-julian"/>
            </xsl:element>-->
            <!--<xsl:call-template name="funcDateFormatTei">
                <xsl:with-param name="pDate">
                    <xsl:call-template name="funcDateG2J">
                        <xsl:with-param name="pDateG" select="$vDate"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="pCal" select="'J'"/>
                <xsl:with-param name="pOutput" select="'formatted'"/>
                <xsl:with-param name="pWeekday" select="true()"/>
            </xsl:call-template>-->
            <xsl:copy-of
                select="oape:date-format-iso-string-to-tei(oape:date-convert-calendars($vDate, '#cal_gregorian', '#cal_julian'), '#cal_julian', true(), true(), 'ar-Latn-x-ijmes')"
            />
        </xsl:if>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Date Rumi']">
        <xsl:element name="date">
            <!-- determine whether the date is Rumi or Mali -->
            <xsl:analyze-string select="." regex=".*(\d{{4}}).*">
                <xsl:matching-substring>
                    <xsl:choose>
                        <!-- is it a good idea to assume that TSS XML contained two different calendars in the same field? -->
                        <!-- al-Muqtabas seems to solely use Ottoman Fiscal dates -->
                        <xsl:when test="number(regex-group(1)) > 1500"> <!-- 1350 -->
                            <xsl:attribute name="calendar" select="'#cal_julian'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_julian'"/>
                            <!-- add machine-actionable data -->
                            <xsl:variable name="v_date-julian"
                                select="oape:date-normalise-input(normalize-space(.), 'ar-Latn-x-sente', '#cal_julian')"/> 
                            <xsl:attribute name="when-custom" select="$v_date-julian"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="calendar" select="'#cal_ottomanfiscal'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_ottomanfiscal'"/>
                            <!-- add machine-actionable data -->
                            <xsl:variable name="v_date-mali"
                                select="oape:date-normalise-input(normalize-space(.), 'ar-Latn-x-sente', '#cal_ottomanfiscal')"/> 
                            <xsl:attribute name="when-custom" select="$v_date-mali"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Date Hijri']">
        <xsl:element name="date">
            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
            <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
            <!-- add machine-actionable data -->
            <xsl:variable name="v_date-hijri"
                select="oape:date-normalise-input(normalize-space(.), 'ar-Latn-x-ijmes', '#cal_islamic')">
            </xsl:variable>
            <xsl:attribute name="when-custom" select="$v_date-hijri"/>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <!-- Titles -->
    <xsl:template match="tss:characteristic[@name = 'publicationTitle']">
        <xsl:element name="title">
            <xsl:attribute name="level">
                <xsl:choose>
                    <xsl:when
                        test="contains(ancestor::tss:reference/tss:publicationType/@name, 'Periodical') or contains(ancestor::tss:reference/tss:publicationType/@name, 'Newspaper')">
                        <xsl:text>j</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>m</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'articleTitle']">
        <xsl:element name="title">
            <xsl:attribute name="level" select="'a'"/>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <!-- Abstract -->
    <xsl:template name="templAbstract">
        <xsl:element name="div">
            <xsl:attribute name="type">abstract</xsl:attribute>
            <xsl:element name="p">
                <!-- In order to preserve existing markup copy-of must be chosen -->
                <xsl:copy-of select=".//tss:characteristic[@name = 'abstractText']/node()"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- IDs -->
    <xsl:template name="templXmlId">
        <xsl:attribute name="xml:id">
            <!-- xml:ids cannot start with a number! why? -->
            <!--<xsl:value-of select="concat('uuid_', replace(.//tss:characteristic[@name='UUID'],'-','_'))"/>-->
            <xsl:value-of select="concat('uuid_', .//tss:characteristic[@name = 'UUID'])"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="t_idno">
        <xsl:call-template name="templSignatur"/>
        <xsl:if
            test=".//tss:publicationType[@name = 'Archival File'] or .//tss:publicationType[@name = 'Archival Letter'] or .//tss:publicationType[@name = 'Archival Material'] or .//tss:publicationType[@name = 'Archival Journal Entry']">
            <xsl:call-template name="templACM"/>
        </xsl:if>
        <xsl:apply-templates select=".//tss:characteristic[@name = 'BibTeX cite tag']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name = 'Citation identifier']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name = 'OCLCID']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name = 'ISBN']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name = 'RIS reference number']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name = 'UUID']"/>
        <xsl:apply-templates select=".//tss:characteristic[@name = 'URL']"/>
    </xsl:template>

    <xsl:template match="tss:characteristic[@name = 'ISBN']">
        <xsl:element name="idno">
            <xsl:attribute name="type">ISBN</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'BibTeX cite tag']">
        <xsl:element name="idno">
            <xsl:attribute name="type">BibTex</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'RIS reference number']">
        <xsl:element name="idno">
            <xsl:attribute name="type">RIS</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'OCLCID']">
        <xsl:element name="idno">
            <xsl:attribute name="type">OCLC</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <!-- Sente UUID -->
    <xsl:template match="tss:characteristic[@name = 'UUID']">
        <xsl:element name="idno">
            <!-- Supposedly XML names cannot contain whitespaces, thus, Sente UUID should be named SenteUUID -->
            <xsl:attribute name="type">SenteUUID</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <!-- Sente ID -->
    <xsl:template match="tss:characteristic[@name = 'Citation identifier']">
        <xsl:element name="idno">
            <xsl:attribute name="type">CitationID</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <!-- Signatur -->
    <xsl:template match="tss:characteristic[@name = 'Signatur']" name="templSignatur">
        <xsl:choose>
            <!-- Check if the Signatur, which is a custom field, matches the call-number -->
            <xsl:when
                test="compare(*//tss:characteristic[@name = 'Signatur'], *//tss:characteristic[@name = 'call-num']) = 0">
                <xsl:call-template name="templCallNum"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- If the reference has no call number this field will be filled with Signatur data -->
                    <xsl:when test="*//tss:characteristic[@name = 'call-num']">
                        <xsl:element name="idno">
                            <xsl:attribute name="type">Signatur</xsl:attribute>
                            <xsl:value-of select="*//tss:characteristic[@name = 'Signatur']"/>
                        </xsl:element>
                        <xsl:call-template name="templCallNum"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="idno">
                            <xsl:attribute name="type">callNumber</xsl:attribute>
                            <xsl:value-of select="*//tss:characteristic[@name = 'Signatur']"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Call Number -->
    <xsl:template match="tss:characteristic[@name = 'call-num']" name="templCallNum">
        <xsl:element name="idno">
            <xsl:attribute name="type">callNumber</xsl:attribute>
            <xsl:value-of select="*//tss:characteristic[@name = 'call-num']"/>
        </xsl:element>
    </xsl:template>
    <!-- URL -->
    <xsl:template match="tss:characteristic[@name = 'URL']">
        <xsl:element name="idno">
            <xsl:attribute name="type" select="'url'"/>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>

    <!-- construct an archival class mark structure -->
    <xsl:template name="templACM">
        <xsl:element name="idno">
            <xsl:attribute name="type">archival-class-mark</xsl:attribute>
            <xsl:value-of select=".//tss:characteristic[@name = 'Repository']"/>
            <xsl:if test=".//tss:characteristic[@name = 'Repository']">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select=".//tss:characteristic[@name = 'Signatur']"/>
            <xsl:if test=".//tss:characteristic[@name = 'publicationCountry']">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select=".//tss:characteristic[@name = 'publicationCountry']"/>
            <xsl:if test=".//tss:characteristic[@name = 'issue']">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select=".//tss:characteristic[@name = 'issue']"/>
        </xsl:element>
    </xsl:template>

    <!-- construct a citation for newspaper artciles -->
    <xsl:template name="templNA">
        <xsl:variable name="vDate">
            <xsl:apply-templates select=".//tss:date[@type = 'Publication']"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test=".//tss:characteristic[@name = 'Short Titel']">
                <xsl:value-of select=".//tss:characteristic[@name = 'Short Titel']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select=".//tss:charateristic[@name = 'publicationTitle']"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:if test=".//tss:characteristic[@name = 'volume'] != ''">
            <xsl:value-of select=".//tss:characteristic[@name = 'volume']"/>
            <xsl:text>-</xsl:text>
        </xsl:if>
        <xsl:value-of select=".//tss:characteristic[@name = 'issue']"/>
    </xsl:template>



    <!-- Publication Type -->
    <!-- this should go as an attribute on the reference's div -->
    <xsl:template name="templType">
        <xsl:attribute name="type">
            <xsl:value-of select="replace(.//tss:publicationType/@name, ' ', '-')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Notes -->
    <xsl:template match="tss:notes" mode="mOrig">
        <xsl:element name="div">
            <xsl:attribute name="type">notes</xsl:attribute>
            <xsl:for-each select=".//tss:note">
                <xsl:sort data-type="text" select="./tss:pages"/>
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
                <xsl:for-each select="./tss:keyword">
                    <xsl:sort data-type="text" order="ascending" select="."/>
                    <xsl:element name="tss:keyword">
                        <!-- The assigner should be retained -->
                        <xsl:attribute name="assigner">
                            <xsl:value-of select="@assigner"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="text()"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tss:keywords" mode="mTEI">
        <xsl:element name="div">
            <xsl:attribute name="type">tags</xsl:attribute>
            <xsl:element name="list">
                <xsl:for-each select="./tss:keyword">
                    <xsl:sort data-type="text" order="ascending" select="."/>
                    <xsl:element name="item">
                        <!-- The assigner should be retained -->
                        <!-- <xsl:attribute name="resp">
                            <xsl:value-of select="@assigner"/>
                        </xsl:attribute> -->
                        <xsl:apply-templates select="text()"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Languages -->
    <!-- the @xml:lang elemnt in TEI must conform to BCP 47. 
        "ar" stands for Arabic language and "Arab" for Arabic script. But we assume that none of the metadata was actually recorded in Sente  in Arabic. Thus, the language code for Arabic should be ar-Latn-x-ijmes, which means that Arabic was rendered into Latin script following the IJMES conventions -->
    <xsl:template name="templLang">
        <xsl:if test="lower-case(.//tss:characteristic[@name = 'language'])">
            <xsl:attribute name="xml:lang">
                <xsl:choose>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name = 'language']) = 'arabic'">
                        <xsl:text>ar-Latn-x-ijmes</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name = 'language']) = 'french'">
                        <xsl:text>fr</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name = 'language']) = 'ottoman turkish'">
                        <xsl:text>ota-Latn-x-ijmes</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name = 'language']) = 'ottoman'">
                        <xsl:text>ota-Latn-x-ijmes</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name = 'language']) = 'turkish'">
                        <xsl:text>tr</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name = 'language']) = 'english'">
                        <xsl:text>en</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="lower-case(.//tss:characteristic[@name = 'language']) = 'german'">
                        <xsl:text>de</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Attachments -->
    <!-- this seems an odd template and necessarily generates errors -->
    <!--<xsl:template match="tss:attachments">
        <xsl:attribute name="facs"
            select="ancestor::tss:reference//tss:attachments/tss:attachmentReference[position()=1]"
        />
    </xsl:template>-->

    <!-- mLocal produces direct links to the image file in the pb tag -->
    <xsl:template match="tss:attachmentReference" mode="mLocal">
        <xsl:choose>
            <xsl:when test="ends-with(./tss:URL, '.jpg')">
                <xsl:element name="pb">
                    <xsl:attribute name="facs" select="./tss:URL"/>
                    <xsl:attribute name="n"
                        select="count(preceding-sibling::tss:attachmentReference) + 1"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="div">
                    <xsl:attribute name="facs" select="./tss:URL"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- mGlobal links to xml:ids of images in the facsimile tag of the TEI file -->
    <xsl:template match="tss:attachmentReference" mode="m_attachment-to-pb">
        <xsl:variable name="vRefUUID"
            select="ancestor::tss:reference//tss:characteristic[@name = 'UUID']"/>
        <xsl:choose>
            <xsl:when test="ends-with(./tss:URL, '.jpg')">
                <xsl:element name="gap">
                    <xsl:attribute name="resp" select="concat('#', $p_editor)"/>
                </xsl:element>
                <xsl:element name="pb">
                    <xsl:attribute name="xml:id"
                        select="concat('pb_', $vRefUUID, '_', count(preceding-sibling::tss:attachmentReference) + 1)"/>
                    <xsl:attribute name="facs"
                        select="concat('#facs_', $vRefUUID, '_', count(preceding-sibling::tss:attachmentReference) + 1)"/>
                    <xsl:attribute name="n"
                        select="count(preceding-sibling::tss:attachmentReference) + 1"/>
                </xsl:element>
                <xsl:element name="gap">
                    <xsl:attribute name="resp" select="concat('#', $p_editor)"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="div">
                    <xsl:attribute name="facs"
                        select="concat('#facs_', $vRefUUID, '_', count(preceding-sibling::tss:attachmentReference) + 1)"
                    />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- generate a list of white-space-separated urls to be used in @facs -->
    <xsl:template match="tss:attachments" mode="m_att.facs">
        <xsl:attribute name="facs">
            <xsl:for-each select="tss:attachmentReference">
                <xsl:if test="ends-with(tss:URL, '.jpg')">
                    <xsl:value-of select="tss:URL"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:attribute>
    </xsl:template>

    <!-- the facsimile tag comes between teiHeader and text -->
    <xsl:template name="t_facsimile">
        <xsl:element name="facsimile">
            <xsl:for-each select="descendant-or-self::tss:reference//tss:attachmentReference">
                <xsl:variable name="vRefUUID"
                    select="ancestor::tss:reference//tss:characteristic[@name = 'UUID']"/>
                <xsl:variable name="vFacsID"
                    select="concat('facs_', $vRefUUID, '_', count(preceding-sibling::tss:attachmentReference) + 1)"/>
                <xsl:element name="surface">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="$vFacsID"/>
                    </xsl:attribute>
                    <xsl:element name="graphic">
                        <xsl:attribute name="url" select="./tss:URL"/>
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="concat($vFacsID, '_source')"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- revisionDesc -->
    <xsl:template name="t_revisionDesc">
        <xsl:element name="revisionDesc">
            <xsl:element name="change">
                <xsl:attribute name="when"
                    select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Generated this file by automatic conversion from Sente XML</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- editionStmt -->
    <xsl:template name="t_editionStmt">
        <xsl:param name="p_editor" select="'Till Grallert'"/>
        <xsl:element name="editionStmt">
            <xsl:element name="edition">
                <xsl:element name="date">
                    <xsl:attribute name="when"
                        select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                    <xsl:value-of select="format-date(current-date(), '[D1] [MNn, *-3]. [Y0001]')"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="respStmt">
                <xsl:element name="resp">
                    <xsl:text>Created the original TEI P5 XML file</xsl:text>
                </xsl:element>
                <xsl:element name="persName">
                    <xsl:attribute name="xml:id">
                        <xsl:text>pers_</xsl:text>
                        <xsl:for-each select="tokenize($p_editor, '\s')">
                            <xsl:value-of select="upper-case(substring(., 1, 1))"/>
                        </xsl:for-each>
                    </xsl:attribute>
                    <xsl:value-of select="$p_editor"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--  correspDesc -->
    <xsl:template name="t_correspDesc">
        <xsl:element name="correspDesc">
            <xsl:element name="correspAction">
                <xsl:attribute name="type" select="'sent'"/>
                <xsl:for-each select="./tss:authors/tss:author[@role = 'Author']">
                    <xsl:element name="persName">
                        <xsl:element name="surname">
                            <xsl:value-of select="./tss:surname"/>
                        </xsl:element>
                        <xsl:text>, </xsl:text>
                        <xsl:element name="forename">
                            <xsl:value-of select="./tss:forenames"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="placeName">
                        <xsl:value-of select=".//tss:characteristic[@name = 'publicationCountry']"/>
                    </xsl:element>
                    <xsl:element name="date">
                        <xsl:call-template name="funcSenteNormalizeDate">
                            <xsl:with-param name="pInput"
                                select=".//tss:date[@type = 'Publication']"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
            <xsl:element name="correspAction">
                <xsl:attribute name="type" select="'received'"/>
                <xsl:element name="persName">
                    <xsl:value-of select=".//tss:characteristic[@name = 'Recipient']"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- normalize space for all text fields -->
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <!-- Still missing fields -->
    <xsl:template match="tss:characteristic[@name = 'affiliation']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">affiliation</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'publicationStatus']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">publicationStatus</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'status']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">status</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Othertype']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Othertype</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Date read']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Date read</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Repository']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Repository</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Standort']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Standort</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Series number']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Series number</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Short Title']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Short Title</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Medium consulted']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Medium consulted</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name = 'Web data source']">
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name">Web data source</xsl:attribute>
            <xsl:apply-templates select="text()"/>
        </xsl:element>
    </xsl:template>



</xsl:stylesheet>
