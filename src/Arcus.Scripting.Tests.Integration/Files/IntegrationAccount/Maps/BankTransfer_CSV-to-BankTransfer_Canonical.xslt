<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" 
                exclude-result-prefixes="msxsl var s0" 
                version="1.0" 
                xmlns:ns0="http://IVT.BankTransfer/Canonical" 
                xmlns:s0="http://IVT.BankTransfer/CSV">
  
  <xsl:output omit-xml-declaration="yes" method="xml" version="1.0" />
  
  <xsl:template match="/">
    <xsl:apply-templates select="/s0:BPF_CSV" />
  </xsl:template>
  
  <xsl:template match="/s0:BPF_CSV">
    <ns0:BankTransferFile>
      <xsl:attribute name="CurrencyCode">
        <xsl:value-of select="s0:BankTransfer/s0:TransactionCurrency/text()" />
      </xsl:attribute>
      <xsl:attribute name="SequenceNumber">
      </xsl:attribute>
      <ns0:BankAccount>
        <ns0:Bank>
          <xsl:value-of select="s0:Bank/s0:Name" />
        </ns0:Bank>
        <ns0:AccountHolder>
          <xsl:value-of select="s0:Bank/s0:AccountHolder" />
        </ns0:AccountHolder>
        <ns0:AccountCode>
          <xsl:value-of select="s0:Bank/s0:AccountCode" />
        </ns0:AccountCode>
        <ns0:Currency>
          <xsl:value-of select="s0:Bank/s0:Currency" />
        </ns0:Currency>
        <ns0:IBAN>
          <xsl:value-of select="s0:Bank/s0:IBAN" />
        </ns0:IBAN>
        <ns0:AccountNumber>
          <xsl:value-of select="s0:Bank/s0:AccountNumber" />
        </ns0:AccountNumber>
        <ns0:SWIFT>
          <xsl:value-of select="s0:Bank/s0:SWIFT" />
        </ns0:SWIFT>
        <ns0:BankCode>
          <xsl:value-of select="s0:Bank/s0:BankCode" />
        </ns0:BankCode>
      </ns0:BankAccount>
      <ns0:BankTransfers>
        <xsl:for-each select="s0:BankTransfer">
          <ns0:BankTransfer>
            <ns0:GCode>
              <xsl:value-of select="s0:GCode/text()" />
            </ns0:GCode>
            <ns0:CreationDate>
              <xsl:value-of select="s0:CreationDate/text()" />
            </ns0:CreationDate>
            <ns0:ValueDate>
              <xsl:value-of select="s0:ValueDate/text()" />
            </ns0:ValueDate>
            <ns0:CustomerAccount>
              <xsl:value-of select="s0:CustomerAccount/text()" />
            </ns0:CustomerAccount>
            <ns0:AccountCurrency>
              <xsl:value-of select="s0:AccountCurrency/text()" />
            </ns0:AccountCurrency>
            <ns0:TransactionAmount>
              <xsl:value-of select="s0:TransactionAmount/text()" />
            </ns0:TransactionAmount>
            <ns0:TransactionCurrency>
              <xsl:value-of select="s0:TransactionCurrency/text()" />
            </ns0:TransactionCurrency>
            <ns0:CreditorAccountNumber>
              <xsl:value-of select="s0:CrediterAccountNumber/text()" />
            </ns0:CreditorAccountNumber>
            <ns0:CreditorName>
              <xsl:value-of select="s0:CrediterName/text()" />
            </ns0:CreditorName>
            <ns0:CreditorBank>
              <xsl:value-of select="s0:CreditorBank/text()" />
            </ns0:CreditorBank>
            <ns0:CreditorBankAddress>
              <xsl:value-of select="s0:CreditorBankAddress/text()" />
            </ns0:CreditorBankAddress>
            <ns0:CreditorBankCity>
              <xsl:value-of select="s0:CreditorBankCity/text()" />
            </ns0:CreditorBankCity>
            <ns0:PlaceHolder_01>
              <xsl:value-of select="s0:PlaceHolder_01/text()" />
            </ns0:PlaceHolder_01>
            <ns0:PaymentDetails_01>
              <xsl:value-of select="s0:PaymentDetails_01/text()" />
            </ns0:PaymentDetails_01>
            <ns0:PaymentDetails_02>
              <xsl:value-of select="s0:PaymentDetails_02/text()" />
            </ns0:PaymentDetails_02>
            <ns0:PaymentDetails_03>
              <xsl:value-of select="s0:PaymentDetails_03/text()" />
            </ns0:PaymentDetails_03>
            <ns0:Charges>
              <xsl:value-of select="s0:Charges/text()" />
            </ns0:Charges>
            <ns0:PlaceHolder_02>
              <xsl:value-of select="s0:PlaceHolder_02/text()" />
            </ns0:PlaceHolder_02>
            <ns0:SWIFTCode>
              <xsl:value-of select="s0:SWIFTCode/text()" />
            </ns0:SWIFTCode>
            <ns0:CreditorAddress>
              <xsl:value-of select="s0:CreditorAddress/text()" />
            </ns0:CreditorAddress>
            <ns0:CreditorCity>
              <xsl:value-of select="s0:CreditorCity/text()" />
            </ns0:CreditorCity>
            <ns0:CreditorCountry>
              <xsl:value-of select="s0:CreditorCountry/text()" />
            </ns0:CreditorCountry>
          </ns0:BankTransfer>
        </xsl:for-each>
      </ns0:BankTransfers>
    </ns0:BankTransferFile>
  </xsl:template>
</xsl:stylesheet>