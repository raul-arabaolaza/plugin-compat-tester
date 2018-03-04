<!--
 *
 * The MIT License
 *
 * Copyright (c) 2004-2010, Sun Microsystems, Inc., Kohsuke Kawaguchi,
 * Erik Ramfelt, Koichi Fujikawa, Red Hat, Inc., Seiji Sogabe,
 * Stephen Connolly, Tom Huybrechts, Yahoo! Inc., Alan Harder, CloudBees, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="html" omit-xml-declaration="no" indent="yes"/>

    <xsl:variable name="testedJenkinsCoordinates" select="/report/testedCoreCoordinates/coord[groupId='org.jenkins-ci.plugins']" />
    <xsl:variable name="testedHudsonCoordinates" select="/report/testedCoreCoordinates/coord[groupId='org.jvnet.hudson.plugins']" />
    <xsl:variable name="otherCoreCoordinates" select="/report/testedCoreCoordinates/coord[not(groupId='org.jenkins-ci.plugins') and not(groupId='org.jvnet.hudson.plugins')]" />

    <xsl:template match="/">
<html>
    <head>
        <title>Plugin compat tester report</title>
        <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>
        <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
        <script type="text/javascript">
            var latestDialog = null;
        </script>

        <style type="text/css">
            th.pluginname {
                width: 200px;
            }
            th.version {
                width: 50px;
            }
            .circle {
                display: inline-block;
                margin: 2px;
                border-radius: 50%;
                height: 24px;
                width: 24px;
            }
            .blue_circle {
                background: radial-gradient(circle at 8px 10px, #5cabff, #000);
            }
            .yellow_circle {
                background: radial-gradient(circle at 8px 10px, #ffff66, #000);
            }
            .red_circle {
                background: radial-gradient(circle at 8px 10px, #ff3333, #000);
            }
            .document {
                display: inline-block;
                margin: 2px;
                height: 24px;
                width: 24px;
                content: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAQAAABKfvVzAAABNklEQVR4XpWRMU4zQQyFP89ONvmlUMIfKQUXoKfnCtBzAG7CBTgANYoUUdFyA46BRIcSkp0ZIyE0luUKr+xm/Om9583K3yoDwOPl7CYDjSONiUKjUig/c6Jw3N6/GsDF0/laSXg9tcnbLWcGMOZPCiMNQaC31XLmLCny+30EQDlFUBxAB+gT/FtUINmjQ5Kx0VKKGZBoqdHMEngNu54BsOefN+QUgqXKCRVibIMd0A2pqXhLNA8A3gxLlghYXA9oN7FCSF3FkHClHTMA3v06oKwioGQGFxPEZRC8AnOqrYLTEDRkcKvxnBL/QyxQ1ggNjZZM8j8J6a32igd6i7Utxyvt2hxlABfXEsBXc8Dz3cs1Mi3qoox1bFkHSC2VNOVjPoz7VA/bKwPgYcOm30YYGBAqVRu++Abw8GiSNi5W4wAAAABJRU5ErkJggg==)
            }
            .terminal {
                display: inline-block;
                margin: 2px;
                height: 24px;
                width: 24px;
                content: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAADyklEQVR4AbSUA4w0WRDHfz3b823v2bZt27btu+Bs246Ts23b1uJs8/O49aqup9LXmfRZlVTq5eGPqp7h/w6fPG6+7bp1fN/fFejjd0Kc4MRlKUgqOHW2Jy7fc7bnOu32TcDTAN55F57Jssss++qcc8yzZLU6KuCfhoKiqCq1ei0cHh4cAVbyusqXW2alh2q1WjA08mZ2OIE88LpZqVDxPIqa5R/tTTrJ5Mw7z4IodO65547N/Cx27SofHH6D62+4hjAMUQDVQpqSV7Xao7h0RyEIAo487BiWXHyZgYrft6tvPUdNebPV5PAT90HFrKI4VEAMWYqqorZWlZxYkXx9+aV30eo0CKOIOI77/N4eOudot9o2MA8pQEToBYaeM833raqSpilOlCgMiaMYX5wUHXepo9lsIAqqxcNCnYqB9BBrlo5O1KITtmh3WrTaDSR1hFFGEEf4ScYI2KCcS2k0WvgDo0iSBImzNKIc0NRipI1mjWa7ThSHduYVn7IJsllGcYKfpklOUCHpOmg0mGX6udl6kz14bfg5ht56hXa9iXpiQK12k3pjAqlLoIAFz5aYK5cKnU7HHPtxxpKm9kOx/tUyB+7rrxn56E2WW3xV1lhxA15661meePwevvvqKww4hy6je+ZASdKEMOwgXYIkjummOjWiRr1BfeJEbv3uKmaeZw6WX2FVVlt+XV4bfJ5P3v+QMm55Q8RwzIGo4EcZeJzENqwkThj902hmXXAuTjvmQqaYbEqeePlhTjj1IL744GNwmussl2JhDtIkxQjECMwBzokNtlZrME0n4uFn7+ORB+5lzLc/oqIFRgmxtAdirU7sK1JV/CT6xYEYexylfDLyIR+9+T4epR54lHtfdmEYIhgegB8lkbVGnNhmHDqIXC8mcy8xP3vvfQBer2q1f2A+eP3d8ldkyguCOHfgehyUVY/7YRwvv/wi5Rj9/Zje+ybACIQegnwGlYrHZJNNxpjv6pQim0Od91/9lL8Sk006qTnsJXDZoG0w+++/vynwPC8jrHSr5Z+E/X6iKCT7V2YgCOiEbfyqD+D8ThjelIHv4pwLyEMVRPhLscjOMUPXKv39/QRBv4EDtNutZoZ5k7fjrtsx95xzv7roIosuiecFIg4VGxKWarVIOyvtudTh+76pbjYbGXi7+ePonwaBNb19DtgTgFartU7Wlr1UNFCVqipZqp9lVVEfpS+rffkwBXBZ+9IsE8/Dap6hE7kWeArA22GXbSnHpx9/6gOjgAEgyGsVqBg+CJACnTxDIAISSuH9PCMTfQZaAgDebA8VxUHAhwAAAABJRU5ErkJggg==)
            }
        </style>
    </head>
    <body>
        <table cellspacing="0" cellpadding="0" border="1">
            <tr>
               <th rowspan="2" colspan="2" class="pluginname">Plugin name</th>
                <xsl:if test="count($testedJenkinsCoordinates) &gt; 0">
                    <xsl:element name="th">
                        <xsl:attribute name="colspan"><xsl:value-of select="count($testedJenkinsCoordinates)" /></xsl:attribute>
                        Jenkins core
                    </xsl:element>
                </xsl:if>
                <xsl:if test="count($testedHudsonCoordinates) &gt; 0">
                    <xsl:element name="th">
                        <xsl:attribute name="colspan"><xsl:value-of select="count($testedHudsonCoordinates)" /></xsl:attribute>
                        Hudson core
                    </xsl:element>
                </xsl:if>
               <xsl:if test="count($otherCoreCoordinates) &gt; 0">
                   <xsl:element name="th">
                       <xsl:attribute name="colspan"><xsl:value-of select="count($otherCoreCoordinates)" /></xsl:attribute>
                       Other core
                   </xsl:element>
               </xsl:if>
            </tr>
            <tr>
                <xsl:for-each select="$testedJenkinsCoordinates" >
                    <th class="version">
                        <xsl:value-of select="version" />
                    </th>
                </xsl:for-each>
                <xsl:for-each select="$testedHudsonCoordinates" >
                    <th class="version">
                        <xsl:value-of select="version" />
                    </th>
                </xsl:for-each>
                <xsl:for-each select="$otherCoreCoordinates" >
                    <th class="version">
                        <xsl:value-of select="version" />
                    </th>
                </xsl:for-each>
            </tr>
            <xsl:apply-templates select="/report/pluginCompatTests/entry">
                <xsl:sort select="pluginInfos/pluginName" />
                <xsl:sort select="pluginInfos/pluginVersion" />
            </xsl:apply-templates>
        </table>
    </body>
</html>
    </xsl:template>

    <xsl:template match="/report/pluginCompatTests/entry">
        <xsl:variable name="currentEntry" select="." />
        <tr>
           <!-- Merging rows having same plugin name -->
           <xsl:if test="not(preceding-sibling::entry/pluginInfos/pluginName = $currentEntry/pluginInfos/pluginName)">
               <xsl:element name="td">
                   <xsl:attribute name="rowspan"><xsl:value-of select="count(//entry[pluginInfos/pluginName=$currentEntry/pluginInfos/pluginName])" /></xsl:attribute>
                   <xsl:value-of select="pluginInfos/pluginName/text()"/>
               </xsl:element>
           </xsl:if>
           <!-- Displaying plugin version -->
           <td><xsl:value-of select="pluginInfos/pluginVersion/text()"/></td>
           <!-- Displaying plugin compilation / test result for every tested core coordinates -->
            <xsl:for-each select="$testedJenkinsCoordinates">
                 <xsl:variable name="compatResult" select="$currentEntry/list/compatResult[./coreCoordinates/version = current()/version and ./coreCoordinates/groupId = current()/groupId and ./coreCoordinates/artifactId = current()/artifactId]" />
                 <xsl:call-template name="display-cell">
                     <xsl:with-param name="compatResult" select="$compatResult" />
                     <xsl:with-param name="pluginInfos" select="$compatResult/../../pluginInfos" />
                 </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="$testedHudsonCoordinates">
                 <xsl:variable name="compatResult" select="$currentEntry/list/compatResult[./coreCoordinates/version = current()/version and ./coreCoordinates/groupId = current()/groupId and ./coreCoordinates/artifactId = current()/artifactId]" />
                 <xsl:call-template name="display-cell">
                     <xsl:with-param name="compatResult" select="$compatResult" />
                     <xsl:with-param name="pluginInfos" select="$compatResult/../../pluginInfos" />
                   </xsl:call-template>
            </xsl:for-each>
           <xsl:for-each select="$otherCoreCoordinates">
                <xsl:variable name="compatResult" select="$currentEntry/list/compatResult[./coreCoordinates/version = current()/version and ./coreCoordinates/groupId = current()/groupId and ./coreCoordinates/artifactId = current()/artifactId]" />
                <xsl:call-template name="display-cell">
                    <xsl:with-param name="compatResult" select="$compatResult" />
                    <xsl:with-param name="pluginInfos" select="$compatResult/../../pluginInfos" />
                </xsl:call-template>
           </xsl:for-each>
        </tr>
    </xsl:template>

    <xsl:template name="display-cell">
        <xsl:param name="compatResult" />
        <xsl:param name="pluginInfos" />
        <xsl:variable name="cellId"><xsl:value-of select="$pluginInfos/pluginName" />-<xsl:value-of select="translate($pluginInfos/pluginVersion, '.', '_')" />_<xsl:value-of select="translate($compatResult/coreCoordinates/groupId, '.', '_')" />_<xsl:value-of select="$compatResult/coreCoordinates/artifactId" />_<xsl:value-of select="translate($compatResult/coreCoordinates/version, '.', '_')" /></xsl:variable>
        <xsl:element name="td">
	  <xsl:attribute name="id"><xsl:value-of select="$cellId" /></xsl:attribute>
            <xsl:choose>
                <xsl:when test="count($compatResult)=0">-----</xsl:when>
                <xsl:otherwise>
		<xsl:choose>
			<xsl:when test="$compatResult/status = 'INTERNAL_ERROR'"><xsl:call-template name="display-internal-error"><xsl:with-param name="id" select="$cellId" /><xsl:with-param name="compatResult" select="$compatResult" /></xsl:call-template></xsl:when>
			<xsl:when test="$compatResult/status = 'COMPILATION_ERROR'"><xsl:call-template name="display-compilation-error"><xsl:with-param name="id" select="$cellId" /><xsl:with-param name="compatResult" select="$compatResult" /></xsl:call-template></xsl:when>
			<xsl:when test="$compatResult/status = 'TEST_FAILURES'"><xsl:call-template name="display-tests-failures"><xsl:with-param name="id" select="$cellId" /><xsl:with-param name="compatResult" select="$compatResult" /></xsl:call-template></xsl:when>
			<xsl:when test="$compatResult/status = 'SUCCESS'"><xsl:call-template name="display-success"><xsl:with-param name="id" select="$cellId" /><xsl:with-param name="compatResult" select="$compatResult" /></xsl:call-template></xsl:when>
		</xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="count($compatResult/warningMessages//string) &gt; 0">
                <xsl:call-template name="display-img">
                    <xsl:with-param name="id"><xsl:value-of select="$cellId"/>-warns</xsl:with-param>
                    <xsl:with-param name="title">Warnings !</xsl:with-param>
                    <xsl:with-param name="img">document.png</xsl:with-param>
                    <xsl:with-param name="error"><xsl:value-of select="$compatResult/warningMessages//string" /></xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$compatResult/buildLogPath != ''">
                <xsl:element name="a">
                    <xsl:attribute name="href"><xsl:value-of select="$compatResult/buildLogPath" /></xsl:attribute>
                    <xsl:call-template name="display-img">
                        <xsl:with-param name="id"><xsl:value-of select="$cellId"/>-logs</xsl:with-param>
                        <xsl:with-param name="title">Logs</xsl:with-param>
                        <xsl:with-param name="img">terminal.png</xsl:with-param>
                        <xsl:with-param name="error">_</xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template name="display-internal-error">
	<xsl:param name="id" />
	<xsl:param name="compatResult" />
	<xsl:call-template name="display-result">
		<xsl:with-param name="id" select="$id" />
		<xsl:with-param name="compilation-title">Compilation : Internal error !</xsl:with-param>
		<xsl:with-param name="compilation-img">red.png</xsl:with-param>
		<xsl:with-param name="compilation-error"><xsl:value-of select="$compatResult/errorMessage" /></xsl:with-param>
		<xsl:with-param name="tests-title">Tests : Internal error !</xsl:with-param>
		<xsl:with-param name="tests-img">red.png</xsl:with-param>
		<xsl:with-param name="tests-error"><xsl:value-of select="$compatResult/errorMessage" /></xsl:with-param>
	</xsl:call-template>
    </xsl:template>

    <xsl:template name="display-compilation-error">
	<xsl:param name="id" />
	<xsl:param name="compatResult" />
	<xsl:call-template name="display-result">
		<xsl:with-param name="id" select="$id" />
		<xsl:with-param name="compilation-title">Compilation : failure !</xsl:with-param>
		<xsl:with-param name="compilation-img">yellow.png</xsl:with-param>
		<xsl:with-param name="compilation-error"><xsl:value-of select="$compatResult/errorMessage" /></xsl:with-param>
		<xsl:with-param name="tests-title">Tests : No tests executed !</xsl:with-param>
		<xsl:with-param name="tests-img">red.png</xsl:with-param>
		<xsl:with-param name="tests-error">Compilation failed => No tests executed !</xsl:with-param>
	</xsl:call-template>
    </xsl:template>

    <xsl:template name="display-tests-failures">
	<xsl:param name="id" />
	<xsl:param name="compatResult" />
	<xsl:call-template name="display-result">
		<xsl:with-param name="id" select="$id" />
		<xsl:with-param name="compilation-title">Compilation : Success !</xsl:with-param>
		<xsl:with-param name="compilation-img">blue.png</xsl:with-param>
		<xsl:with-param name="compilation-error">_</xsl:with-param>
		<xsl:with-param name="tests-title">Tests : Some tests are in failure !</xsl:with-param>
		<xsl:with-param name="tests-img">yellow.png</xsl:with-param>
		<xsl:with-param name="tests-error"><xsl:value-of select="$compatResult/errorMessage" /></xsl:with-param>
	</xsl:call-template>
    </xsl:template>

    <xsl:template name="display-success">
	<xsl:param name="id" />
	<xsl:param name="compatResult" />
	<xsl:call-template name="display-result">
		<xsl:with-param name="id" select="$id" />
		<xsl:with-param name="compilation-title">Compilation : Success !</xsl:with-param>
		<xsl:with-param name="compilation-img">blue.png</xsl:with-param>
		<xsl:with-param name="compilation-error">_</xsl:with-param>
		<xsl:with-param name="tests-title">Tests : Success !</xsl:with-param>
		<xsl:with-param name="tests-img">blue.png</xsl:with-param>
		<xsl:with-param name="tests-error">_</xsl:with-param>
	</xsl:call-template>
    </xsl:template>

    <xsl:template name="display-result">
        <xsl:param name="id" />
        <xsl:param name="compilation-title"/>
        <xsl:param name="compilation-img" />
        <xsl:param name="compilation-error" />
        <xsl:param name="tests-title" />
        <xsl:param name="tests-img" />
        <xsl:param name="tests-error" />
        <xsl:call-template name="display-img">
            <xsl:with-param name="id"><xsl:value-of select="$id"/>-compilation</xsl:with-param>
            <xsl:with-param name="title" select="$compilation-title" />
            <xsl:with-param name="img" select="$compilation-img" />
            <xsl:with-param name="error" select="$compilation-error" />
        </xsl:call-template>
        <xsl:call-template name="display-img">
            <xsl:with-param name="id"><xsl:value-of select="$id"/>-tests</xsl:with-param>
            <xsl:with-param name="title" select="$tests-title" />
            <xsl:with-param name="img" select="$tests-img" />
            <xsl:with-param name="error" select="$tests-error" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="display-img">
        <xsl:param name="id" />
        <xsl:param name="title" />
        <xsl:param name="img" />
        <xsl:param name="error" />

	<xsl:element name="span">
	    <xsl:attribute name="id"><xsl:value-of select="$id" /></xsl:attribute>
	    <xsl:attribute name="alt"><xsl:value-of select="$title" /></xsl:attribute>
	    <xsl:attribute name="title"><xsl:value-of select="$title" /><xsl:if test="not($error='_')"><xsl:value-of select="$error" /></xsl:if></xsl:attribute>
	    <xsl:choose>
	        <xsl:when test="$img='blue.png'">
	            <xsl:attribute name="class">circle blue_circle</xsl:attribute>
	        </xsl:when>
	        <xsl:when test="$img='red.png'">
	            <xsl:attribute name="class">circle red_circle</xsl:attribute>
	        </xsl:when>
	        <xsl:when test="$img='yellow.png'">
	            <xsl:attribute name="class">circle yellow_circle</xsl:attribute>
	        </xsl:when>
            <xsl:when test="$img='document.png'">
                <xsl:attribute name="class">document</xsl:attribute>
            </xsl:when>
            <xsl:when test="$img='terminal.png'">
	            <xsl:attribute name="class">terminal</xsl:attribute>
	        </xsl:when>
	    </xsl:choose>
	    <xsl:if test="not($error='_')">
		<xsl:attribute name="onclick">if(latestDialog!=null){ $(latestDialog).dialog('close'); } latestDialog="#<xsl:value-of select="$id" />_dialog"; $("#<xsl:value-of select="$id" />_dialog").dialog();</xsl:attribute>
	    </xsl:if>
	</xsl:element>
	<xsl:if test="not($error='_')">
		<xsl:element name="span">
		    <xsl:attribute name="id"><xsl:value-of select="$id" />_dialog</xsl:attribute>
		    <xsl:attribute name="title"><xsl:value-of select="$title" /></xsl:attribute>
		    <xsl:attribute name="style">display:none</xsl:attribute>
		    <pre><xsl:value-of select="$error" /></pre>
		</xsl:element>
	</xsl:if>
    </xsl:template>

    <xsl:template match="text()">
    </xsl:template>

</xsl:stylesheet>