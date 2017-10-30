<?xml version="1.0" encoding="UTF-8"?>
<!-- Exemple avec le serveur OAi de Persée, requête de type  http://oai.persee.fr/oai?verb=ListRecords&metadataPrefix=oai_dc&set=
La feuille de style prend en entrée la 1ère page de résultats issue de la requête et ouvre récursivement chaque page suivante.
La copie de chaque record dans un fichier séparé n'est pas super pertinente ici, c'est juste pour l'exemple -->
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
xmlns:dc="http://purl.org/dc/elements/1.1/" 
xmlns:dcterms="http://purl.org/dc/terms/" 
version="2.0" 
exclude-result-prefixes="xs oai dc dcterms">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
  <!-- Mettre en paramètre le chemin absolu du dossier où déposer les ficihiers, par exemple  file:///C:/Users/...-->
    <xsl:param name="file_uri">file:///G:/persee-oai/</xsl:param>
    <!-- le premier resumptionToken -->
    <xsl:param name="token" select="oai:ListRecords/oai:resumptionToken"/>
    <!-- on met en paramètre le nombre total d'enregistrements -->
    <xsl:param name="listSize" select="oai:ListRecords/oai:resumptionToken/@completeListSize"/>
    <!-- On compte le nombre d'enregistrements par page de résultats -->
    <xsl:param name="countRecords" select="count(oai:ListRecords/oai:record)"/>
      <xsl:for-each select="oai:ListRecords/oai:record">
      <xsl:variable name="name" select="concat($file_uri,substring-after(oai:header/oai:identifier,'/'),'.xml')"/>
      <xsl:result-document href="{$name}">
        <root>
<xsl:copy-of select="oai:metadata" />
        </root>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:call-template name="recursion">
      <xsl:with-param name="min" select="0"/>
      <!-- On calcule le nombre d'appels au template -->
      <xsl:with-param name="max" select="floor(number($listSize) div $countRecords + 1)"/>
      <xsl:with-param name="token" select="$token"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="recursion">
    <xsl:param name="token"/>
    <xsl:param name="min"/>
    <xsl:param name="max"/>
    <xsl:for-each select="document(concat('http://oai.persee.fr/oai?verb=ListRecords&amp;resumptionToken=',$token))//oai:ListRecords/oai:record">
      <xsl:variable name="name" select="concat($file_uri,substring-after(oai:header/oai:identifier,'/'),'.xml')"/>
      <xsl:result-document href="{$name}">
        <root>
<xsl:copy-of select="oai:metadata" />
        </root>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:if test="number($min) &lt; number($max)">
      <xsl:call-template name="recursion">
        <xsl:with-param name="min" select="$min + 1"/>
        <xsl:with-param name="max" select="$max"/>
        <xsl:with-param name="token" select="document(concat('http://oai.persee.fr/oai?verb=ListRecords&amp;resumptionToken=',$token))//oai:ListRecords/oai:resumptionToken"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>


