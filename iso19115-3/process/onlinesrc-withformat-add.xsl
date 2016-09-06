<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all" >
  
  <!-- TODO: could be nice to define the target distributor -->
  
  <xsl:param name="uuidref"/>
  <xsl:param name="extra_metadata_uuid"/>
  <xsl:param name="protocol" select="'OGC:WMS-1.1.1-http-get-map'"/>
  <xsl:param name="url"/>
  <xsl:param name="name"/>
  <xsl:param name="desc"/>
  <xsl:param name="format"/>
  <xsl:param name="version"/>
  
  <xsl:template match="/mdb:MD_Metadata|*[contains(@gco:isoType, 'mdb:MD_Metadata')]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="mdb:metadataIdentifier"/>
      <xsl:apply-templates select="mdb:defaultLocale"/>
      <xsl:apply-templates select="mdb:parentMetadata"/>
      <xsl:apply-templates select="mdb:metadataScope"/>
      <xsl:apply-templates select="mdb:contact"/>
      <xsl:apply-templates select="mdb:dateInfo"/>
      <xsl:apply-templates select="mdb:metadataStandard"/>
      <xsl:apply-templates select="mdb:metadataProfile"/>
      <xsl:apply-templates select="mdb:alternativeMetadataReference"/>
      <xsl:apply-templates select="mdb:otherLocale"/>
      <xsl:apply-templates select="mdb:metadataLinkage"/>
      <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
      <xsl:apply-templates select="mdb:referenceSystemInfo"/>
      <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
      <xsl:apply-templates select="mdb:identificationInfo"/>
      <xsl:apply-templates select="mdb:contentInfo"/>
      
      
      <xsl:choose>
        <xsl:when test="count(mdb:distributionInfo) = 0">
          <mdb:distributionInfo>
            <mrd:MD_Distribution>
                <xsl:call-template name="fill"/>
            </mrd:MD_Distribution>
          </mdb:distributionInfo>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="mdb:distributionInfo">
            <xsl:copy>
              <xsl:copy-of select="@*"/>
              <mrd:MD_Distribution>
								<xsl:copy-of select="mrd:MD_Distribution/*"/>
                <xsl:call-template name="fill"/>
              </mrd:MD_Distribution>
            </xsl:copy>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:apply-templates select="mdb:dataQualityInfo"/>
      <xsl:apply-templates select="mdb:resourceLineage"/>
      <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="mdb:metadataConstraints"/>
      <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
      <xsl:apply-templates select="mdb:metadataMaintenance"/>
      <xsl:apply-templates select="mdb:acquisitionInformation"/>
      
    </xsl:copy>
  </xsl:template>
  
  <!-- Remove geonet:* elements. -->
  <xsl:template match="gn:*" priority="2"/>
  
  <!-- Copy everything. -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="fill">
    <!-- Add all online source from the target metadata to the
                    current one -->
    <xsl:if test="//extra">
      <xsl:for-each select="//extra//mrd:onLine">
        <mrd:onLine>
          <xsl:if test="$extra_metadata_uuid">
            <xsl:attribute name="uuidref" select="$extra_metadata_uuid"/>
          </xsl:if>
          <xsl:copy-of select="*"/>
        </mrd:onLine>
      </xsl:for-each>
      <xsl:for-each select="//extra//mrd:distributionFormat[descendant::mrd:onLine]">
        <mrd:distributionFormat>
          <xsl:if test="$extra_metadata_uuid">
            <xsl:attribute name="uuidref" select="$extra_metadata_uuid"/>
          </xsl:if>
          <xsl:copy-of select="*"/>
        </mrd:distributionFormat>
      </xsl:for-each>
    </xsl:if>
    
    <!-- Add online source from URL -->
    <xsl:if test="$url">
      <xsl:for-each select="tokenize($name, ',')">
        <xsl:variable name="pos" select="position()"/>
							<mrd:distributionFormat>
								<mrd:MD_Format>
									<mrd:formatSpecificationCitation>
										<cit:CI_Citation>
											<cit:title>
												<gco:CharacterString><xsl:value-of select="$format"/></gco:CharacterString>
											</cit:title>
											<cit:date>
												<cit:CI_Date>
													<!-- TODO: do what with this? -->
													<cit:date gco:nilReason="missing"/>
													<cit:dateType gco:nilReason="missing"/>
												</cit:CI_Date>
											</cit:date>
											<cit:edition>
												<gco:CharacterString><xsl:value-of select="$version"/></gco:CharacterString>
											</cit:edition>
										</cit:CI_Citation>
									</mrd:formatSpecificationCitation>
									<mrd:formatDistributor>
										<mrd:MD_Distributor>
											<mrd:distributorContact>
												<cit:CI_Responsibility>
                					<cit:role>
                  					<cit:CI_RoleCode codeList="http://asdd.ga.gov.au/asdd/profileinfo/gmxCodelists.xml#CI_RoleCode" codeListValue="distributor">distributor</cit:CI_RoleCode>
                					</cit:role>
													<cit:party>
														<cit:CI_Organisation>
															<cit:name>
																<gco:CharacterString>Geoscience Australia</gco:CharacterString>
															</cit:name>
															<cit:contactInfo>
                  							<cit:CI_Contact>
               										<cit:phone>
                  										<cit:CI_Telephone>
                     										<cit:number>
                          									<gco:CharacterString>+61 2 6249 9966</gco:CharacterString>
                     										</cit:number>
                     										<cit:numberType>
                        										<cit:CI_TelephoneTypeCode codeList="codeListLocation#CI_TelephoneTypeCode" codeListValue="voice">voice</cit:CI_TelephoneTypeCode>
                     										</cit:numberType>
                  										</cit:CI_Telephone>
               										</cit:phone>
               										<cit:phone>
                  										<cit:CI_Telephone>
                     										<cit:number>
                          									<gco:CharacterString>+61 2 6249 9960</gco:CharacterString>
                     										</cit:number>
                     										<cit:numberType>
                        										<cit:CI_TelephoneTypeCode codeList="codeListLocation#CI_TelephoneTypeCode" codeListValue="facsimile">facsimile</cit:CI_TelephoneTypeCode>
                     										</cit:numberType>
                  										</cit:CI_Telephone>
               										</cit:phone>
                    							<cit:address>
                      							<cit:CI_Address>
                        							<cit:deliveryPoint>
                          							<gco:CharacterString>GPO Box 378</gco:CharacterString>
                        							</cit:deliveryPoint>
                        							<cit:city>
                          							<gco:CharacterString>Canberra</gco:CharacterString>
                        							</cit:city>
                        							<cit:administrativeArea>
                          							<gco:CharacterString>ACT</gco:CharacterString>
                        							</cit:administrativeArea>
                        							<cit:postalCode>
                          							<gco:CharacterString>2601</gco:CharacterString>
                        							</cit:postalCode>
                        							<cit:country>
                          							<gco:CharacterString>Australia</gco:CharacterString>
                        							</cit:country>
                        							<cit:electronicMailAddress>
                          							<gco:CharacterString>sales@ga.gov.au</gco:CharacterString>
                        							</cit:electronicMailAddress>
                      							</cit:CI_Address>
                    							</cit:address>
                  							</cit:CI_Contact>
                							</cit:contactInfo>
														</cit:CI_Organisation>
													</cit:party>
												</cit:CI_Responsibility>
											</mrd:distributorContact>
              				<mrd:distributorTransferOptions>
                				<mrd:MD_DigitalTransferOptions>
        									<mrd:onLine>
          									<cit:CI_OnlineResource>
            									<cit:linkage>
              									<gco:CharacterString>
                									<xsl:value-of select="$url"/>
              									</gco:CharacterString>
            									</cit:linkage>
            									<cit:protocol>
              									<gco:CharacterString>
                									<xsl:value-of select="$protocol"/>
              									</gco:CharacterString>
            									</cit:protocol>
            									<cit:name>
              									<gco:CharacterString>
                									<xsl:value-of select="."/>
              									</gco:CharacterString>
            									</cit:name>
            									<cit:description>
              									<gco:CharacterString>
                									<xsl:value-of select="tokenize($desc, ',')[position() = $pos]"/>
              									</gco:CharacterString>
            									</cit:description>
          									</cit:CI_OnlineResource>
        									</mrd:onLine>
                				</mrd:MD_DigitalTransferOptions>
              				</mrd:distributorTransferOptions>
										</mrd:MD_Distributor>
									</mrd:formatDistributor>
								</mrd:MD_Format>
							</mrd:distributionFormat>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
