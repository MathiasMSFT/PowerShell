# Setup one timeout value for downloadstring method of WebClient Class
#
# Property Timeout of WebClient isn't public, but we can inhertis from him and change this property in the new class
#
# Inspired by: One article on What Was I Thinking? (http://goo.gl/IQQazD)
# Thanks also to Stefan GoÃƒï¿½ner (http://goo.gl/T6RZJC)
#
# run sample: powershell.exe -executionpolicy bypass .\DownloadString.ps1 100 "http://www.google.es"
# run sample: powershell.exe -executionpolicy bypass .\DownloadString.ps1 -url "http://www.google.es" -timeout -1
Param(
  [string]$timeout, 	#input parameter (Download String Timeout).
  [string]$url			#input parameter (url to Download).
)
 
 
$Source = @"
	using System.Net;
 
	public class ExtendedWebClient : WebClient
	{
		public int Timeout;
 
		protected override WebRequest GetWebRequest(System.Uri address)
		{
			WebRequest request = base.GetWebRequest(address);
			if (request != null)
			{
				request.Timeout = Timeout;
			}
			return request;
		}
 
		public ExtendedWebClient()
		{
			Timeout = 100000; // the standard HTTP Request Timeout default
		}
	}
"@;
 
Add-Type -TypeDefinition $Source -Language CSharp  
 
$webclient = New-Object ExtendedWebClient;
$webclient.Timeout=$timeout;
$webclient.downloadstring($url);
$webclient