<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<!--
  The following template changes the original "togenum" element format:

    <togenum name="signal-name" siga="count-of-siga" sigb="count-of-sigb" .../>

  to something which can be validated with a DTD:

    <togenum name="signal-name">
      <enumvalue name="siga" c="count-of-siga"/>
      <enumvalue name="sigb" c="count-of-sigb"/>
      ...
    </togenum>

  Everything else in the input XML is passed to the output intact.
  -->

<xsl:template match="togenum">
  <xsl:copy>
    <xsl:copy-of select="@name"/>
    <xsl:for-each select="@*[name() != 'name']">
      <xsl:element name="togenumval">
        <xsl:attribute name="name"><xsl:value-of select="name(.)"/></xsl:attribute>
        <xsl:attribute name="c"><xsl:value-of select="."/></xsl:attribute>
      </xsl:element>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<xsl:template match="*">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
