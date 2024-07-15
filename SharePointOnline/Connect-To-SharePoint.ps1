cls
$assemblies = ("System.Core","System.Xml.Linq","System.Data","System.Xml", "System.Data.DataSetExtensions", "Microsoft.CSharp")
#using OfficeDevPnP.Core;
#using Microsoft.SharePoint;
#using Microsoft.SharePoint.Client;

$code = @"
using Microsoft.SharePoint.Publishing.Administration;
using System;
using Microsoft.SharePoint;
using Microsoft.SharePoint.Client;

namespace Sharepoint 
{
    public static class WebSite 
    {
        public static void Get()
        {
            string siteUrl = "https://identityms.sharepoint.com";  
            using (var cc = new AuthenticationManager().GetAppOnlyAuthenticatedContext(siteUrl, "mathias.dumont@identityms.onmicrosoft.com", "1!uxSkKK0XAs4LC"))  
            {  
                cc.Load(cc.Web, p => p.Title);  
                cc.ExecuteQuery();  
                Console.WriteLine(cc.Web.Title);  
            }
        } 
         
        public static void Set(int seconds)
        {
            ContentDeploymentConfiguration cdconfig = ContentDeploymentConfiguration.GetInstance();
            cdconfig.RemoteTimeout = seconds;
            cdconfig.Update();
        }
    }
}
"@

Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $code -Language CSharp

[Sharepoint.WebSite]::Get()

#iex "[Sharepoint.Website]"


