<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes"/>

<!--
  This stylesheet converts the Jasper GamePlan XML format to something more acceptable
  to the xml2ucdb test plan import tool. The main changes involve converting the design
  coverage item links from being full-fledged nodes in the hierarchy (as created by the
  GamePlan utility) into data items within the parent testplan section.
  -->

<!-- BEGIN USER MODIFICATION AREA -->

<!--
  This is a comma-separated list of user-defined field names that may appear as the value
  of the "name" attribute if ab "ATTR_VAL" element. These are converted to data fields in
  the output XML file with the field name added as a leading keyword in the element text.
  White space is ignored in processing this list. The PATH attribute is also considered a
  user-defined attribute so, if used, it should be incldued here.
  -->

<xsl:variable name="user-attrs">PATH,RESPONSIBLE</xsl:variable>

<!-- END USER MODIFICATION AREA -->

<!--
  The TESTPLAN document element becomes our document node. It contains one or more PLAN
  elements and nothing else.
  -->

<xsl:template match="TESTPLAN">
  <xsl:element name="TESTPLAN">
    <xsl:apply-templates select="PLAN"/>
  </xsl:element>
</xsl:template>

<!--
  The PLAN element is a top-level testplan section. It contains the usual NAME and DESC and
  one or more FEATURE elements.
  -->

<xsl:template match="PLAN">
  <xsl:element name="PLAN">
    <xsl:apply-templates select="NAME|DESC|FEATURE"/>
  </xsl:element>
</xsl:template>

<!--
  The following elements are converted to nested testplan sections. The contents must be
  processed in the sequence they are to appear in the output.  Otherwise the children of
  this element would appear in document order.
  -->

<xsl:template match="FEATURE|HLR|GROUP|COVERAGE|PROPERTY|TESTCASE">
  <xsl:element name="{name(.)}">
    <xsl:apply-templates select="NAME|DESC"/>
    <xsl:apply-templates select="UDA/ATTR_VAL"/>
    <xsl:apply-templates select="COVERAGE|PROPERTY|TESTCASE"/>
    <xsl:apply-templates select="FEATURE|HLR|GROUP"/>
  </xsl:element>
</xsl:template>

<!--
  This template processes LINK and TYPE fields. The value of the latest TYPE field is saved
  off and used when the next LINK field is seen.
  -->

<xsl:template match="ATTR_VAL[@name='LINK']">
  <!--
    This XPATH magick nets us the last ATTR_VAL of @name "TYPE" prior to this ATTR_VAL.
    -->
  <xsl:variable name="type" select="preceding-sibling::ATTR_VAL[@name='TYPE'][last()]"/>
  <xsl:element name="LINK">
    <xsl:attribute name="type">
      <xsl:value-of select="normalize-space($type)"/>
    </xsl:attribute>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:element>
</xsl:template>

<!--
  This template processes fields whose name matches recognized field keywords built-into
  xml2ucdb. Do not include TYPE or LINK (or any fields listed in "user-attrs") here.
  -->

<xsl:template match="ATTR_VAL[@name='GOAL' or @name='WEIGHT']">
  <xsl:element name="{@name}">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:element>
</xsl:template>

<!--
  This template processes fields whose name matches one of the keywords listed in the global
  user attribute list (user-attrs) at the top of this stylesheet. The first template calls a
  canned template to "walk" the user-attrs values. The second template (user-attr) is called
  for every ATTR_VAL whose @name matches a keyword in that list.
  -->

<xsl:template match="ATTR_VAL">
  <xsl:call-template name="if-user-attr">
    <xsl:with-param name="name" select="@name"/>
    <xsl:with-param name="keys" select="$user-attrs"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="user-attr">
  <xsl:param name="name"/>
  <xsl:element name="UserData">
    <xsl:value-of select="$name"/><xsl:text>: </xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:element>
</xsl:template>

<!--
  This is the recursive user-attribute matching template. Don't mess with this unless you
  really know how XSLT works. This is a recursive template. There is no user-code in this
  template. See the "user-attr" template above for the output XML code.
  -->

<xsl:template name="if-user-attr">
  <xsl:param name="name"/>
  <xsl:param name="keys"/>
  <xsl:if test="string-length($keys) > 0">
    <!-- extract next keyword from user-attrs -->
    <xsl:variable name="attr">
      <xsl:choose>
        <xsl:when test="contains($keys, ',')">
          <xsl:value-of select="substring-before($keys, ',')"/>
        </xsl:when>
        <xsl:otherwise><!-- only one attr name left in "keys" -->
          <xsl:value-of select="$keys"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- emit user attr on a match, else keep looking -->
    <xsl:choose>
      <xsl:when test="$name = normalize-space($attr)">
        <xsl:call-template name="user-attr">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><!-- still looking -->
        <xsl:call-template name="if-user-attr">
          <xsl:with-param name="name" select="$name"/>
          <xsl:with-param name="keys" select="substring-after($keys, ',')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<!--
  Names and descriptions have a direct counterpart in xml2ucdb.
  -->

<xsl:template match="NAME|DESC">
  <xsl:element name="{name(.)}">
    <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>

<!--
  This allows us to bypass unnecessary nodes while preventing their contents from
  appearing in the output sans markup. If the templates above are correct (and no
  undefined elements show up in the incoming data), this template should never be
  invoked.
  -->

<xsl:template match="node()|@*">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
