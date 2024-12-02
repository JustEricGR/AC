<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
  Select text output and strip ignorable whitespace from incoming XML file
  -->

<xsl:output method="text" encoding="UTF-8"/>
<xsl:strip-space elements="*"/>

<!--
  The following template forces a newline and a number of spaces depending
  on the depth of the XML element from which it is called (ie: indentation).
  This template is invoked prior to each output line to emit leading spaces
  based on the depth of the element at hand.
  -->

<xsl:template name="indent">
  <xsl:text>&#10;</xsl:text>
  <xsl:for-each select="ancestor::*">&#160;&#160;</xsl:for-each>
</xsl:template>

<!--
  An arbitrarily long string (for padding attribute names)
  -->

<xsl:variable name="padstr">                                                                       </xsl:variable>

<!--
  Top-level elements
  -->

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="coverage_report">
  <xsl:apply-templates/>
</xsl:template>

<!--
  Code coverage elements
  -->

<xsl:template match="code_coverage_report">
  <xsl:call-template name="indent"/>=== Code Coverage Report ===<xsl:text/>
  <xsl:if test="@summary">
  <xsl:call-template name="indent"/>Summary Mode: on<xsl:text/></xsl:if>
  <xsl:if test="@zeros">
  <xsl:call-template name="indent"/>Mode to display objects having zero counts: on<xsl:text/></xsl:if>
  <xsl:if test="@lines">
  <xsl:call-template name="indent"/>Mode to display individual lines: on<xsl:text/></xsl:if>
  <xsl:if test="@sourcePath">
  <xsl:call-template name="indent"/>Report only on file: <xsl:value-of select="@sourcePath"/></xsl:if>
  <xsl:if test="@instancePath">
  <xsl:call-template name="indent"/>Report only on instance: <xsl:value-of select="@instancePath"/></xsl:if>
  <xsl:if test="@all">
  <xsl:call-template name="indent"/>Display all toggle signals: on<xsl:text/></xsl:if>
  <xsl:if test="@totals">
  <xsl:call-template name="indent"/>Display only totals: on<xsl:text/></xsl:if>
  <xsl:if test="@byInstance">
  <xsl:call-template name="indent"/>Report by Instance: on<xsl:text/></xsl:if>
  <xsl:if test="@byDU">
  <xsl:call-template name="indent"/>Report by Design Unit: on<xsl:text/></xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="summaryByFile">
  <xsl:call-template name="indent"/>Summary of coverage by File:<xsl:text/>
  <xsl:call-template name="indent"/>  Number of Files: <xsl:value-of select="@files"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="summaryByInstance">
  <xsl:call-template name="indent"/>Summary of coverage by Instance:<xsl:text/>
  <xsl:call-template name="indent"/>  Number of Instances: <xsl:value-of select="@instances"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="fileData">
  <xsl:call-template name="indent"/>Coverage by File:<xsl:text/>
  <xsl:call-template name="indent"/>  File path: <xsl:value-of select="@path"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="instanceData">
  <xsl:call-template name="indent"/>Coverage by Instance:<xsl:text/>
  <xsl:call-template name="indent"/>  Instance path: <xsl:value-of select="@path"/>
  <xsl:call-template name="indent"/>  Design Unit  : <xsl:value-of select="@du"/><xsl:if test="@sec">
  <xsl:call-template name="indent"/>  Architecture : <xsl:value-of select="@sec"/></xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="DuData">
  <xsl:call-template name="indent"/>Coverage by Design Unit:<xsl:text/>
  <xsl:call-template name="indent"/>  Design Unit : <xsl:value-of select="@du"/><xsl:if test="@sec">
  <xsl:call-template name="indent"/>  Architecture: <xsl:value-of select="@sec"/></xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="sourceTable">
  <xsl:call-template name="indent"/>Table of Source Files for Design Unit:<xsl:text/>
  <xsl:call-template name="indent"/>  Number of files: <xsl:value-of select="@files"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="fileMap">
  <xsl:call-template name="indent"/>File mapping:<xsl:text/>
  <xsl:call-template name="indent"/>  File number: <xsl:value-of select="@fn"/>
  <xsl:call-template name="indent"/>  Path       : <xsl:value-of select="@path"/>
</xsl:template>

<xsl:template match="statements">
  <xsl:call-template name="indent"/>Statements:<xsl:text/>
  <xsl:call-template name="indent"/>  Active : <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Hits   : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent: <xsl:value-of select="@percent"/>
</xsl:template>

<xsl:template match="stmt">
  <xsl:call-template name="indent"/>Statement:<xsl:text/>
  <xsl:if test="@fn">
  <xsl:call-template name="indent"/>  File number: <xsl:value-of select="@fn"/></xsl:if>
  <xsl:call-template name="indent"/>  Line number: <xsl:value-of select="@ln"/>
  <xsl:call-template name="indent"/>  Stmt number: <xsl:value-of select="@st"/>
  <xsl:call-template name="indent"/>  Hit count  : <xsl:value-of select="@hits"/>
</xsl:template>

<xsl:template match="branches">
  <xsl:call-template name="indent"/>Branches:<xsl:text/>
  <xsl:call-template name="indent"/>  Active : <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Hits   : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent: <xsl:value-of select="@percent"/>
</xsl:template>

<xsl:template match="if">
  <xsl:call-template name="indent"/>Branch coverage for IF statement:<xsl:text/>
  <xsl:call-template name="indent"/>  Active branches: <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Branches hit   : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent for IF : <xsl:value-of select="@percent"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="case">
  <xsl:call-template name="indent"/>Branch coverage for CASE statement:<xsl:text/>
  <xsl:call-template name="indent"/>  Active branches : <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Branches hit    : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent for CASE: <xsl:value-of select="@percent"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="conditions">
  <xsl:call-template name="indent"/>Conditions:<xsl:text/>
  <xsl:call-template name="indent"/>  Active : <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Hits   : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent: <xsl:value-of select="@percent"/>
</xsl:template>

<xsl:template match="condition">
  <xsl:call-template name="indent"/>Condition:<xsl:text/>
  <xsl:if test="@fn">
  <xsl:call-template name="indent"/>  File number: <xsl:value-of select="@fn"/></xsl:if>
  <xsl:call-template name="indent"/>  Line number: <xsl:value-of select="@ln"/>
  <xsl:call-template name="indent"/>  Stmt number: <xsl:value-of select="@st"/>
  <xsl:call-template name="indent"/>  Num terms  : <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Terms hit  : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent    : <xsl:value-of select="@percent"/>
</xsl:template>

<xsl:template match="expressions">
  <xsl:call-template name="indent"/>Expressions:<xsl:text/>
  <xsl:call-template name="indent"/>  Active : <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Hits   : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent: <xsl:value-of select="@percent"/>
</xsl:template>

<xsl:template match="expression">
  <xsl:call-template name="indent"/>Expression:<xsl:text/>
  <xsl:if test="@fn">
  <xsl:call-template name="indent"/>  File number: <xsl:value-of select="@fn"/></xsl:if>
  <xsl:call-template name="indent"/>  Line number: <xsl:value-of select="@ln"/>
  <xsl:call-template name="indent"/>  Stmt number: <xsl:value-of select="@st"/>
  <xsl:call-template name="indent"/>  Num terms  : <xsl:value-of select="@active"/>
  <xsl:call-template name="indent"/>  Terms hit  : <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Percent    : <xsl:value-of select="@percent"/>
</xsl:template>

<xsl:template match="toggleSummary">
  <xsl:call-template name="indent"/>Summary of signals toggled:<xsl:text/>
  <xsl:call-template name="indent"/>  Total Signals: <xsl:value-of select="@total"/>
  <xsl:call-template name="indent"/>  Num Toggled  : <xsl:value-of select="@toggled"/>
  <xsl:call-template name="indent"/>  Percent      : <xsl:value-of select="@percent"/>
</xsl:template>

<xsl:template match="tog">
  <xsl:call-template name="indent"/>Signal: <xsl:value-of select="@name"/>
  <xsl:call-template name="indent"/>  To Zero: <xsl:value-of select="@c0"/>
  <xsl:call-template name="indent"/>  To One : <xsl:value-of select="@c1"/>
</xsl:template>

<!--
  The attribute names emitted by the current version of the code are different from those
  recognized by the original XSL file :: manhole...
  -->
<xsl:template match="toge">
  <xsl:call-template name="indent"/>Signal: <xsl:value-of select="@name"/>
  <xsl:call-template name="indent"/>  One To Zero: <xsl:value-of select="@c1H_0L"/>
  <xsl:call-template name="indent"/>  Zero To One: <xsl:value-of select="@c0L_1H"/>
  <xsl:call-template name="indent"/>  Zero To Unk: <xsl:value-of select="@c0L_Z"/>
  <xsl:call-template name="indent"/>  Unk To Zero: <xsl:value-of select="@cZ_0L"/>
  <xsl:call-template name="indent"/>  One To Unk : <xsl:value-of select="@c1H_Z"/>
  <xsl:call-template name="indent"/>  Unk To One : <xsl:value-of select="@cZ_1H"/>
</xsl:template>

<!--
  The "oldstyle" and "newstyle" modes refer to the format of the "togenum"
  element which may have been translated in order to enable DTD validation.
  -->
<xsl:template match="togenum">
  <xsl:apply-templates select="." mode="newstyle"/>
</xsl:template>

<!--
  The following template processes the new "togenum" format.
  -->
<xsl:template match="togenum" mode="newstyle">
  <xsl:call-template name="indent"/>Enumerated signal: <xsl:value-of select="@name"/>
    <!-- find the max-length name from all the child "togenumval" elements -->
    <xsl:variable name="maxstr">
      <xsl:for-each select="togenumval">
        <xsl:sort select="string-length(@name)" data-type="number" order="descending"/>
        <xsl:if test="position()=1"><xsl:value-of select="@name"/></xsl:if>
      </xsl:for-each>
    </xsl:variable>
	<!-- process child "togenumval" elements passing the width of the longest child name -->
    <xsl:apply-templates mode="newstyle">
      <xsl:with-param name="width"><xsl:value-of select="string-length($maxstr)"/></xsl:with-param>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="togenumval" mode="newstyle">
  <xsl:param name="width"/>
  <xsl:variable name="signal" select="substring(concat(@name, $padstr), 1, $width)"/>
  <xsl:call-template name="indent"/>  To <xsl:value-of select="$signal"/>: <xsl:value-of select="@c"/>
</xsl:template>

<!--
  The following template processes the old "togenum" format. This nonsense is necessary
  because the attributes of the "togenum" element are signal names from the design whose
  values cannot be predicted before the file is processed. There is a stylesheet which
  will convert the old style to the new style. (JLL 25 Apr 2007)
  -->
<xsl:template match="togenum" mode="oldstyle">
    <xsl:call-template name="indent"/>Enumerated signal: <xsl:value-of select="@name"/>
    <!-- find the max-length attribute name (not counting the "name" attribute) -->
    <xsl:variable name="maxstr">
      <xsl:for-each select="@*[local-name() != 'name']">
        <xsl:sort select="string-length(local-name())" data-type="number" order="descending"/>
        <xsl:if test="position()=1"><xsl:value-of select="name(.)"/></xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="@*[local-name() != 'name']"><xsl:text>
      </xsl:text>
      <xsl:value-of select="substring(concat(name(.), $padstr), 1, string-length($maxstr))"/>: <xsl:value-of select="."/>
    </xsl:for-each>
</xsl:template>

<xsl:template match="ielem">
  <xsl:call-template name="indent"/>IF statement element:<xsl:text/>
  <xsl:if test="@fn">
  <xsl:call-template name="indent"/>  File number: <xsl:value-of select="@fn"/></xsl:if>
  <xsl:call-template name="indent"/>  Line number: <xsl:value-of select="@ln"/>
  <xsl:call-template name="indent"/>  Stmt number: <xsl:value-of select="@st"/>
  <xsl:call-template name="indent"/>  True hits  : <xsl:value-of select="@true"/>
  <xsl:call-template name="indent"/>  False hits : <xsl:value-of select="@false"/>
</xsl:template>

<xsl:template match="celem">
  <xsl:call-template name="indent"/>CASE statement element:<xsl:text/>
  <xsl:if test="@fn">
  <xsl:call-template name="indent"/>  File number: <xsl:value-of select="@fn"/></xsl:if>
  <xsl:call-template name="indent"/>  Line number: <xsl:value-of select="@ln"/>
  <xsl:call-template name="indent"/>  Stmt number: <xsl:value-of select="@st"/>
  <xsl:call-template name="indent"/>  Num hits   : <xsl:value-of select="@hits"/>
</xsl:template>

<xsl:template match="table">
  <xsl:call-template name="indent"/>Truth Table:<xsl:text/>
  <xsl:call-template name="indent"/>  Number of rows: <xsl:value-of select="@rows"/>
  <xsl:call-template name="indent"/>  Number of cols: <xsl:value-of select="@cols"/>
  <xsl:call-template name="indent"/>  Unknown cases : <xsl:value-of select="@unknown"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="col">
  <xsl:call-template name="indent"/>Col: <xsl:value-of select="@i"/>
  <xsl:call-template name="indent"/>  Label: <xsl:value-of select="@label"/>
</xsl:template>

<xsl:template match="row">
  <xsl:call-template name="indent"/>Row: <xsl:value-of select="@i"/>
  <xsl:call-template name="indent"/>  Hits: <xsl:value-of select="@hits"/>
  <xsl:call-template name="indent"/>  Body: <xsl:value-of select="@body"/>
</xsl:template>

<xsl:template match="file"><!-- this may not be used any more -->
  <xsl:call-template name="indent"/>Data for file: <xsl:value-of select="@path"/>
  <xsl:apply-templates/>
</xsl:template>

<!--
  Functional coverage elements
  -->

<xsl:template match="functional_coverage_report">
  <xsl:call-template name="indent"/>=== Functional Coverage Report ===<xsl:text/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="cvgreport">
  <xsl:call-template name="indent"/>Covergroups:<xsl:text/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="covertype">
  <xsl:call-template name="indent"/>Cover Type:<xsl:text/>
  <xsl:call-template name="indent"/>  Path: <xsl:value-of select="path"/>
  <xsl:apply-templates select="*[not(self::path)]"/>
</xsl:template>

<xsl:template match="coverinstance">
  <xsl:call-template name="indent"/>Cover Instance:<xsl:text/>
  <xsl:call-template name="indent"/>  Path: <xsl:value-of select="path"/>
  <xsl:apply-templates select="*[not(self::path)]"/>
</xsl:template>

<xsl:template match="coverpoint">
  <xsl:call-template name="indent"/>Coverpoint:<xsl:text/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="cross">
  <xsl:call-template name="indent"/>Cross:<xsl:text/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="cross_coverpoints">
  <xsl:call-template name="indent"/>Cross coverpoints:<xsl:text/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="cross_coverpoint">
  <xsl:call-template name="indent"/>Coverpoint: <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="bins">
  <xsl:call-template name="indent"/>Bins:<xsl:text/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="bin">
  <xsl:call-template name="indent"/>Bin:<xsl:text/>
  <xsl:call-template name="indent"/>  Name  : <xsl:value-of select="name"/>
  <xsl:call-template name="indent"/>  Metric: <xsl:value-of select="metric"/>
  <xsl:call-template name="indent"/>  Goal  : <xsl:value-of select="goal"/>
  <xsl:call-template name="indent"/>  Status: <xsl:value-of select="status"/>
  <xsl:if test="bin_rhs">
  <xsl:call-template name="indent"/>  Rhs:    <xsl:value-of select="bin_rhs"/></xsl:if>
</xsl:template>

<xsl:template match="ignore_bins">
  <xsl:call-template name="indent"/>Ignore bins:<xsl:text/>
  <xsl:call-template name="indent"/>  Name  : <xsl:value-of select="name"/>
  <xsl:call-template name="indent"/>  Metric: <xsl:value-of select="metric"/>
  <xsl:call-template name="indent"/>  Goal  : <xsl:value-of select="goal"/>
  <xsl:call-template name="indent"/>  Status: <xsl:value-of select="status"/>
  <xsl:if test="bin_rhs">
  <xsl:call-template name="indent"/>  Rhs   : <xsl:value-of select="bin_rhs"/></xsl:if>
</xsl:template>

<xsl:template match="illegal_bins">
  <xsl:call-template name="indent"/>Illegal bins:<xsl:text/>
  <xsl:call-template name="indent"/>  Name  : <xsl:value-of select="name"/>
  <xsl:call-template name="indent"/>  Metric: <xsl:value-of select="metric"/>
  <xsl:call-template name="indent"/>  Goal  : <xsl:value-of select="goal"/>
  <xsl:call-template name="indent"/>  Status: <xsl:value-of select="status"/>
  <xsl:if test="bin_rhs">
  <xsl:call-template name="indent"/>  Rhs   : <xsl:value-of select="bin_rhs"/></xsl:if>
</xsl:template>

<xsl:template match="type_option">
  <xsl:call-template name="indent"/>Option:<xsl:text/>
  <xsl:call-template name="indent"/>  Weight : <xsl:value-of select="weight"/>
  <xsl:call-template name="indent"/>  Goal   : <xsl:value-of select="goal"/>
  <xsl:call-template name="indent"/>  Comment: <xsl:value-of select="comment"/>
  <xsl:if test="strobe">
  <xsl:call-template name="indent"/>  Strobe : <xsl:value-of select="strobe"/></xsl:if>
</xsl:template>

<xsl:template match="option">
  <xsl:call-template name="indent"/>Option:<xsl:text/>
  <xsl:if test="name">
  <xsl:call-template name="indent"/>  Name       : <xsl:value-of select="name"/></xsl:if>
  <xsl:if test="weight">
  <xsl:call-template name="indent"/>  Weight     : <xsl:value-of select="weight"/></xsl:if>
  <xsl:if test="goal">
  <xsl:call-template name="indent"/>  Goal       : <xsl:value-of select="goal"/></xsl:if>
  <xsl:if test="comment">
  <xsl:call-template name="indent"/>  Comment    : <xsl:value-of select="comment"/></xsl:if>
  <xsl:if test="at_least">
  <xsl:call-template name="indent"/>  At least   : <xsl:value-of select="at_least"/></xsl:if>
  <xsl:if test="auto_bin_max">
  <xsl:call-template name="indent"/>  Auto max   : <xsl:value-of select="auto_bin_max"/></xsl:if>
  <xsl:if test="per_instance">
  <xsl:call-template name="indent"/>  Per inst   : <xsl:value-of select="per_instance"/></xsl:if>
  <xsl:if test="detect_overlap">
  <xsl:call-template name="indent"/>  Det overlap: <xsl:value-of select="detect_overlap"/></xsl:if>
  <xsl:if test="cross_num_print_missing">
  <xsl:call-template name="indent"/>  Prt missing: <xsl:value-of select="cross_num_print_missing"/></xsl:if>
</xsl:template>

<xsl:template match="design">
  <xsl:call-template name="indent"/>Design:<xsl:text/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="fcover">
  <xsl:call-template name="indent"/>Fcover:<xsl:text/>
  <xsl:if test="name">
  <xsl:call-template name="indent"/>  Name       : <xsl:value-of select="name"/></xsl:if>
  <xsl:if test="du">
  <xsl:call-template name="indent"/>  Design unit: <xsl:value-of select="du"/></xsl:if>
  <xsl:if test="dutype">
  <xsl:call-template name="indent"/>  DU type    : <xsl:value-of select="dutype"/></xsl:if>
  <xsl:if test="dirtype">
  <xsl:call-template name="indent"/>  Dir type   : <xsl:value-of select="dirtype"/></xsl:if>
  <xsl:if test="source">
  <xsl:call-template name="indent"/>  Source     : <xsl:value-of select="source"/></xsl:if>
  <xsl:if test="count">
  <xsl:call-template name="indent"/>  Count      : <xsl:value-of select="count"/></xsl:if>
  <xsl:if test="status">
  <xsl:call-template name="indent"/>  Status     : <xsl:value-of select="status"/></xsl:if>
</xsl:template>

</xsl:stylesheet>
