<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
  xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:gn="http://www.fao.org/geonetwork"
	xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  exclude-result-prefixes="#all">


  <!-- Readonly elements - the rules in this template
       will only match if the element at the root of the xpath is used
			 in config-editor.xml -->
  <xsl:template mode="mode-iso19115-3"
                match="mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code|
                       mdb:metadataIdentifier/mcc:MD_Identifier/mcc:codeSpace|
                       mdb:metadataIdentifier/mcc:MD_Identifier/mcc:description|
                       mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date|
                       mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:dateType|
                       mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date|
                       mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:dateType"
                priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="*/@codeListValue"><xsl:value-of select="*/@codeListValue"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="gn-fn-metadata:getLabel($schema, name(), $labels)/label"/>
      <xsl:with-param name="value" select="$value"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '')"/>
      <xsl:with-param name="name" select="''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="isDisabled" select="true()"/>
    </xsl:call-template>

  </xsl:template>

  <!-- Readonly element - alternativeMetadataReference for eCatId
       will only match if the element at the root of the xpath is used
			 in config-editor.xml -->
  <xsl:template mode="mode-iso19115-3"
                match="mdb:alternativeMetadataReference[cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString='http://www.ga.gov.au/eCatId']"
                priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

		<xsl:for-each select="cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code">

    	<xsl:call-template name="render-element">
      	<xsl:with-param name="label" select="'eCat ID'"/>
      	<xsl:with-param name="value" select="gco:CharacterString"/>
      	<xsl:with-param name="cls" select="local-name()"/>
      	<xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      	<xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '')"/>
      	<xsl:with-param name="name" select="'eCat ID'"/>
      	<xsl:with-param name="editInfo" select="*/gn:element"/>
      	<xsl:with-param name="parentEditInfo" select="gn:element"/>
      	<xsl:with-param name="isDisabled" select="true()"/>
    	</xsl:call-template>

		</xsl:for-each>

  </xsl:template>

  <!-- Duration

       xsd:duration elements use the following format:

       Format: PnYnMnDTnHnMnS

       *  P indicates the period (required)
       * nY indicates the number of years
       * nM indicates the number of months
       * nD indicates the number of days
       * T indicates the start of a time section (required if you are going to specify hours, minutes, or seconds)
       * nH indicates the number of hours
       * nM indicates the number of minutes
       * nS indicates the number of seconds

       A custom directive is created.
  -->
  <xsl:template mode="mode-iso19115-3"
                match="gts:TM_PeriodDuration|gml:duration"
                priority="2000">

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)/label"/>
      <xsl:with-param name="value" select="."/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="directive" select="'gn-field-duration'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
    </xsl:call-template>

  </xsl:template>

  <!-- ===================================================================== -->
  <!-- gml32:TimePeriod (format = %Y-%m-%dThh:mm:ss) -->
  <!-- ===================================================================== -->

  <xsl:template mode="mode-iso19115-3" match="gml:beginPosition|gml:endPosition|gml:timePosition" priority="2000">
		<xsl:param name="schema" select="$schema" required="no"/>
		<xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="value" select="normalize-space(text())"/>


		<xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels)"/>

		<div data-gn-date-picker="{.}"
				 data-tag-name=""
				 data-label="{$labelConfig/label}"
				 data-element-name="{name()}"
				 data-element-ref="{concat('_',gn:element/@ref)}"
				 data-namespaces='{{ "gco": "http://standards.iso.org/iso/19115/-3/gco/1.0", "gml": "http://www.opengis.net/gml/3.2"}}'>
		</div>

		<!--
    <xsl:variable name="attributes">
      <xsl:if test="$isEditing">
        <!- - Create form for all existing attribute (not in gn namespace)
        and all non existing attributes not already present. - ->
        <xsl:apply-templates mode="render-for-field-for-attribute"
                             select="             @*|           gn:attribute[not(@name = parent::node()/@*/name())]">
          <xsl:with-param name="ref" select="gn:element/@ref"/>
          <xsl:with-param name="insertRef" select="gn:element/@ref"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>


    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)/label"/>
      <xsl:with-param name="name" select="gn:element/@ref"/>
      <xsl:with-param name="value" select="text()"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <!- -
          Default field type is Date.

          TODO : Add the capability to edit those elements as:
           * xs:time
           * xs:dateTime
           * xs:anyURI
           * xs:decimal
           * gml:CalDate
          See http://trac.osgeo.org/geonetwork/ticket/661
        - ->
      <xsl:with-param name="type"
                      select="if (string-length($value) = 10 or $value = '') then 'date' else 'datetime'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
    </xsl:call-template>
		-->
  </xsl:template>

  <xsl:template mode="mode-iso19115-3"
                match="gex:EX_GeographicBoundingBox"
                priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label"
        select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)/label"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="subTreeSnippet">
        <div gn-draw-bbox="" data-hleft="{gex:westBoundLongitude/gco:Decimal}"
          data-hright="{gex:eastBoundLongitude/gco:Decimal}" data-hbottom="{gex:southBoundLatitude/gco:Decimal}"
          data-htop="{gex:northBoundLatitude/gco:Decimal}" data-hleft-ref="_{gex:westBoundLongitude/gco:Decimal/gn:element/@ref}"
          data-hright-ref="_{gex:eastBoundLongitude/gco:Decimal/gn:element/@ref}"
          data-hbottom-ref="_{gex:southBoundLatitude/gco:Decimal/gn:element/@ref}"
          data-htop-ref="_{gex:northBoundLatitude/gco:Decimal/gn:element/@ref}"
          data-lang="lang"></div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="mode-iso19115-3"
          match="gml:Polygon"
          priority="2000">
    <textarea>
      <xsl:copy-of select="."/>
    </textarea>
  </xsl:template>

  <!-- Custom rendering of constraints sections mri:resourceConstraints and 
	  * mdb:metadataConstraints is boxed element and the 
		* title of the fieldset is the name of the child element
  -->
  <xsl:template mode="mode-iso19115-3" priority="33000" match="mri:resourceConstraints|mdb:metadataConstraints">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>

    <xsl:variable name="attributes">
      <xsl:if test="$isEditing">
        <!-- Create form for all existing attribute (not in gn namespace)
        and all non existing attributes not already present. -->
        <xsl:apply-templates mode="render-for-field-for-attribute"
          select="
          @*|
          gn:attribute[not(@name = parent::node()/@*/name())]">
          <xsl:with-param name="ref" select="gn:element/@ref"/>
          <xsl:with-param name="insertRef" select="gn:element/@ref"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label"
        select="gn-fn-metadata:getLabel($schema, name(*[1]), $labels, name(), $isoType, $xpath)/label"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
      <xsl:with-param name="subTreeSnippet">
        <xsl:apply-templates mode="mode-iso19115-3" select="*">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="labels" select="$labels"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

	<!-- Show xlink'd individuals and contacts -->
	<xsl:template mode="party-html" match="cit:individual">
		<ul>
			<li style="list-style-type: none;">
				<xsl:if test="normalize-space(descendant::cit:name/gco:CharacterString)">
				  <xsl:value-of select="string(descendant::cit:name/gco:CharacterString)"/>
				  <xsl:if test="normalize-space(descendant::cit:positionName/gco:CharacterString)">
						<xsl:value-of select="', '"/>
					</xsl:if>
				</xsl:if>
				<xsl:if test="normalize-space(descendant::cit:positionName/gco:CharacterString)">
					<xsl:value-of select="descendant::cit:positionName/gco:CharacterString"/>
				</xsl:if>
			</li>
		</ul>
	</xsl:template>

	<xsl:template mode="party-html" match="cit:contactInfo">
		<xsl:param name="organisationName"/>

		<ul>
			<li style="list-style-type: none;"><xsl:value-of select="$organisationName"/></li>
			<li style="list-style-type: none;"><xsl:value-of select="descendant::cit:deliveryPoint/gco:CharacterString"/></li>
			<li style="list-style-type: none;"><xsl:value-of select="descendant::cit:city/gco:CharacterString"/></li>
			<li style="list-style-type: none;"><xsl:value-of select="descendant::cit:administrativeArea/gco:CharacterString"/></li>
			<li style="list-style-type: none;"><xsl:value-of select="concat(descendant::cit:country/gco:CharacterString,' ',descendant::cit:postalCode/gco:CharacterString)"/></li>
			<xsl:if test="normalize-space(descendant::cit:electronicMailAddress/gco:CharacterString)">
				<li style="list-style-type: none;"><xsl:value-of select="concat('Email: ',descendant::cit:electronicMailAddress/gco:CharacterString)"/></li>
			</xsl:if>
			<xsl:if test="normalize-space(descendant::cit:voice/gco:CharacterString)">
				<li style="list-style-type: none;"><xsl:value-of select="concat('Phone: ',descendant::cit:voice/gco:CharacterString)"/></li>
			</xsl:if>
		</ul>
	</xsl:template>

  <!-- XLINK'd cit:party 
	 eg. <cit:party xlink:href="http://test.cmar.csiro.au:80/geonetwork/srv/eng/subtemplate?uuid=urn:marlin.csiro.au:person:958_person_organisation&amp;process=undefined">
	       ....
	     </cit:party>
	-->
  <xsl:template mode="mode-iso19115-3" match="mri:pointOfContact[@xlink:href!='']|mdb:contact[@xlink:href!='']" priority="33000">
    <xsl:param name="schema" select="'iso19115-3'" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

		<xsl:variable name="organisationName" select="*/cit:party/*/cit:name/*"/>
		<fieldset>
			<legend><xsl:value-of select="gn-fn-metadata:getLabel($schema, name(), $labels)/label"/></legend>
			<xsl:apply-templates mode="party-html" select="*/cit:party/*/cit:individual"/>
				<!-- NOTE: Show only the first address in the contact info SP Nov. 2015 -->
			<xsl:apply-templates mode="party-html" select="*/cit:party/*/cit:contactInfo[1]">
				<xsl:with-param name="organisationName" select="$organisationName"/>
			</xsl:apply-templates>
		</fieldset>
  </xsl:template>


</xsl:stylesheet>
