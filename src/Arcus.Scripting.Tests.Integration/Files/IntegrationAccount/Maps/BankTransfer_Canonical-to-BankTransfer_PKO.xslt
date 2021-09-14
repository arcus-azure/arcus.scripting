<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var"
                exclude-result-prefixes="msxsl var s0"
                version="1.0"
                xmlns:s0="http://IVT.BankTransfer/Canonical"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:ns0="http://IVT.BankTransfer/PKO/EUR/Outbound_CSV">

  <xsl:output omit-xml-declaration="yes" method="xml" version="1.0" />

  <xsl:template match="/">
    <xsl:apply-templates select="/s0:BankTransferFile" />
  </xsl:template>

  <xsl:template match="/s0:BankTransferFile">
    <ns0:BPF_CSV>
      <xsl:for-each select="s0:BankTransfers/s0:BankTransfer">
        <ns0:BankTransfer>
          <ns0:ValueDate>
            <xsl:value-of select="s0:ValueDate"/>
          </ns0:ValueDate>
          <ns0:TransactionAmount>
            <xsl:value-of select="format-number(s0:TransactionAmount, '0.00')"/>
          </ns0:TransactionAmount>
          <ns0:Currency>
            <xsl:value-of select="s0:AccountCurrency"/>
          </ns0:Currency>
          <ns0:CustomerAccount>
            <xsl:value-of select="s0:CustomerAccount"/>
          </ns0:CustomerAccount>
          <ns0:BeneficiarySWIFTCode>
            <xsl:value-of select="s0:SWIFTCode"/>
          </ns0:BeneficiarySWIFTCode>
          <ns0:BeneficiaryBankCountry>
            <xsl:value-of select="s0:CreditorBankAddress"/>
          </ns0:BeneficiaryBankCountry>
          <ns0:BeneficiaryAccountNumber>
            <xsl:value-of select="s0:CreditorAccountNumber"/>
          </ns0:BeneficiaryAccountNumber>
          <ns0:BeneficiaryNameAndAddress>
            <xsl:value-of select="s0:CreditorName"/>
          </ns0:BeneficiaryNameAndAddress>
          <ns0:CustomerReference>
            <xsl:value-of select="s0:PaymentDetails_01"/>
          </ns0:CustomerReference>
          <ns0:BeneficiaryCountry>
            <xsl:value-of select="s0:CreditorCountry"/>
          </ns0:BeneficiaryCountry>
          <ns0:CustomerFeeAccount>
            <xsl:value-of select="s0:CustomerAccount"/>
          </ns0:CustomerFeeAccount>
          <ns0:FeeInstructions>
            <xsl:text>SHA</xsl:text>
          </ns0:FeeInstructions>
          <ns0:PaymentDetails>
            <xsl:text>MONTHLY SALARY</xsl:text>
          </ns0:PaymentDetails>
        </ns0:BankTransfer>
      </xsl:for-each>
    </ns0:BPF_CSV>
  </xsl:template>
</xsl:stylesheet>