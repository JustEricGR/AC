<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml"/>

  <xsl:param name="indent-increment" select="'  '"/>

  <xsl:template match="/">
    <xsl:apply-templates>
      <xsl:with-param name="indent" select="'&#xA;'"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="indent"/>

    <xsl:value-of select="$indent"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="indent" select="concat($indent, $indent-increment)"/>
      </xsl:apply-templates>
      <xsl:if test="*">
        <xsl:value-of select="$indent"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()|processing-instruction()">
    <xsl:param name="indent"/>

    <xsl:if test="preceding-sibling::node()[1][not(self::*)]">
      <xsl:value-of select="$indent"/>
    </xsl:if>
    <xsl:copy/>
  </xsl:template>

  <!-- WARNING: this is dangerous. Handle with care -->
  <xsl:template match="text()[normalize-space(.)='']"/>

  <!-- <xsl:template match="text()">
    <xsl:copy/>
  </xsl:template> -->

</xsl:stylesheet>
