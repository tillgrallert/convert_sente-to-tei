<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0"
    >
    
    <!-- this stylesheet produces correctly formatted references in a TEI file from a Sente XML library file. It searches the TEI file for Sente Citation IDs in currly braces and seperated by semi-colons, extracts these strings, queries the Sente XML library for reference with these citation IDs and returns either a correctly formatted bibliographic reference or – in case the Sente XML library does not contain such a citation ID – the original citation ID.
    The bibliographic style can be changed through the paramater pgBibStyle -->
    <!-- the citaed pages identifier @ is passed on to funcCitation -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v1.xsl"/>
    
    <xsl:param name="pgSenteLibrary" select="document('/BachUni/projekte/XML/Sente XML exports/sources 130409 escaped.xml')"/>
    <xsl:param name="pgBibStyle" select="'C15TillArchBib'"/>
    
    
    
    <xsl:template match="tei:*">
        <xsl:if test="contains(.,'{')">
            <xsl:for-each select="tokenize(.,'\{')">
              <xsl:choose>
                  <xsl:when test="contains(.,'}')">
                      <xsl:variable name="vCitationIDs" select="substring-before(.,'}')"/>
                      <xsl:for-each select="$vCitationIDs">
                          <xsl:choose>
                              <xsl:when test="contains($vCitationIDs,';')">
                                  <xsl:for-each select="tokenize($vCitationIDs,';\s*')">
                                      <xsl:call-template name="tCitLookUp">
                                          <xsl:with-param name="pCitID" select="."/>
                                      </xsl:call-template>
                                      <xsl:if test="position()!=last()">
                                          <xsl:text>, </xsl:text>
                                      </xsl:if>
                                  </xsl:for-each>
                              </xsl:when>
                              <xsl:otherwise>
                                  <xsl:call-template name="tCitLookUp">
                                      <xsl:with-param name="pCitID" select="$vCitationIDs"/>
                                  </xsl:call-template>
                              </xsl:otherwise>
                          </xsl:choose>
                      </xsl:for-each>
                      <xsl:copy-of select="substring-after(.,'}')"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:copy-of select="."/>
                  </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="tCitLookUp">
        <xsl:param name="pCitID"/>
        <!-- this variable splits potential page strings from the pCitID -->
        <xsl:variable name="vCitId">
            <xsl:choose>
                <xsl:when test="contains($pCitID,'@')">
                    <xsl:value-of select="substring-before($pCitID,'@')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pCitID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vCitedPages">
            <xsl:if test="contains($pCitID,'@')">
                <xsl:value-of select="substring-after($pCitID,'@')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$pgSenteLibrary//tss:reference[.//tss:characteristic[@name='Citation identifier']=$vCitId]">
                <xsl:for-each select="$pgSenteLibrary//tss:reference[.//tss:characteristic[@name='Citation identifier']=$vCitId]">
                    <xsl:call-template name="funcCitation">
                        <xsl:with-param name="pRef" select="."/>
                        <xsl:with-param name="pBibStyle" select="$pgBibStyle"/>
                        <xsl:with-param name="pCitedPages" select="$vCitedPages"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('{',$pCitID,'}')"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>