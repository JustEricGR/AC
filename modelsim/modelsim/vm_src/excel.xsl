<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
>

<xsl:output method="xml" indent="yes"/>

<!--
  This stylesheet converts the "abbreviated" Excel 2003 XML format (where empty
  cells are omitted from the data output) to a "canonical" format in which all
  cells are represented even if they are empty. (JLL 29 Apr 2008)
  -->

<!-- BEGIN USER MODIFICATION AREA -->

<!--
  The "first-col" variable may contain the (1-based) index of the first column
  of the spreadsheet which is used for real testplan data. If this value is not
  supplied, the stylesheet will attempt to figure it out by looking at the data
  set to try to find the first non-blank column.
  -->

<xsl:variable name="first-col"></xsl:variable><!-- minimum real column -->

<!--
  The "max-jump" variable contains the maximum number of replacement cells this
  stylesheet will insert. This is to prevent a runnaway situation where the last
  cell in a row is given a very high number (256 in the case of OpenOffice).
  -->

<xsl:variable name="max-jump">20</xsl:variable><!-- maximum column jump -->

<!-- END USER MODIFICATION AREA -->

<!--
  This XSL magick plucks the column offset, if any, out of the first cell in the
  spreadsheet. If no cells exist, or if the first non-blank cell is sans-index,
  no columns will be skipped.
  -->

<xsl:variable name="skip-col">
  <xsl:for-each select="(//ss:Cell[1])[1]">
    <xsl:choose>
      <!-- user-specified value takes priority -->
      <xsl:when test="string($first-col)">
        <xsl:value-of select="$first-col"/>
      </xsl:when>
      <!-- grab starting column, if specified -->
      <xsl:when test="string(@ss:Index)">
        <xsl:value-of select="@ss:Index"/>
      </xsl:when>
      <!-- or, start in column one by default -->
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:variable>

<!--
  This template handles a single row of the spreadsheet. We need to handle Rows
  seperately because only the first cell should be passed from this level.. the
  other cells in the row are handles in a chain by the ss:Cell template.
  -->

<xsl:template match="ss:Row">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="ss:Cell[1]">
			<xsl:with-param name="column" select="1"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<!--
  This template makes sure that any skipped cells are reinstated.
  -->

<xsl:template match="ss:Cell">
	<xsl:param name="column"/>
	<xsl:param name="index" select="@ss:Index"/>
	<xsl:if test="$index and (number($index) &gt; $skip-col)">
		<!-- index exists and is valid, add extra cells if needed -->
		<xsl:if test="(number($index) - number($column)) &lt;= $max-jump">
			<xsl:call-template name="extra-cells">
				<xsl:with-param name="n" select="number($index) - number($column)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:if>
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
	<!-- Process "ss:Cell" elements one-by-one, counting each time -->
	<xsl:apply-templates select="following-sibling::*[1]">
		<xsl:with-param name="column">
			<xsl:choose>
				<xsl:when test="$index"><xsl:value-of select="$index + 1"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$column + 1"/></xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template name="extra-cells">
	<xsl:param name="n"/>
	<xsl:if test="number($n) > 0">
		<Cell/><!-- Adding extra cell (DO NOT use a namespace on this element) -->
		<xsl:call-template name="extra-cells">
			<xsl:with-param name="n" select="number($n) - 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!--
  This template ensures that any elements not addressed above are passed through.
  -->

<xsl:template match="node()|@*">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
