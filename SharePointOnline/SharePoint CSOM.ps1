Add-PSSnapin Microsoft.SharePoint.PowerShell

$dlls = (
    "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll", 
    "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll", 
    "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
)

$assem = @()

foreach($dll in $dlls){
    $assem += [System.Reflection.AssemblyName]::GetAssemblyName($dll).FullName
}

$source = @" 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.SharePoint.Client;
using Microsoft.SharePoint.Client.Social;

namespace RefollowSites
{
    public static class Program
    {
        static ClientContext clientContext;
        static SocialFollowingManager followingManager;
        public static void Refollow()
        {

            // Replace the following placeholder values with the URL of the target
            // server and target document (or site).
            const string serverUrl = "https://intranet.engineerer.ch";
            const string contentUrl = @"https://intranet.engineerer.ch/sites/test"; 
            const SocialActorType contentType = SocialActorType.Site;

            // Get the client context.
            clientContext = new ClientContext(serverUrl);

            // Get the SocialFeedManager instance.
            followingManager = new SocialFollowingManager(clientContext);

            // Create a SocialActorInfo object to represent the target item.
            SocialActorInfo actorInfo = new SocialActorInfo();
            actorInfo.ContentUri = contentUrl;
            actorInfo.ActorType = contentType;

            // Find out whether the current user is following the target item.
            ClientResult<bool> isFollowed = followingManager.IsFollowed(actorInfo);

            // Get the information from the server.
            clientContext.ExecuteQuery();

            Console.WriteLine("Was the current user following the target {0}? {1}\\n",
                actorInfo.ActorType.ToString().ToLower(), isFollowed.Value);
            Console.Write("Initial count: ");

            // Get the current count of followed items.
            WriteFollowedCount(actorInfo.ActorType);

            // Try to follow the target item. If the result is OK, then
            // the request succeeded.
            ClientResult<SocialFollowResult> result = followingManager.Follow(actorInfo);
            clientContext.ExecuteQuery();

            // If the result is AlreadyFollowing, then stop following 
            // the target item.
            if (result.Value == SocialFollowResult.AlreadyFollowing)
            {
                followingManager.StopFollowing(actorInfo);
                clientContext.ExecuteQuery();
            }

            // Handle other SocialFollowResult return values.
            else if (result.Value == SocialFollowResult.LimitReached
                || result.Value == SocialFollowResult.InternalError)
            {
                Console.WriteLine(result.Value);
            }

            // Get the updated count of followed items.
            Console.Write("Updated count: ");
            WriteFollowedCount(actorInfo.ActorType);
            Console.ReadKey();
        }

        // Get the count of the items that the current user is following.
        static void WriteFollowedCount(SocialActorType type)
        {

            // Set the parameter for the GetFollowedCount method, and
            // handle the case where the item is a site. 
            SocialActorTypes types = SocialActorTypes.Documents;
            if (type != SocialActorType.Document)
            {
                types = SocialActorTypes.Sites;
            }

            ClientResult<int> followedCount = followingManager.GetFollowedCount(types);
            clientContext.ExecuteQuery();
            Console.WriteLine("{0} followed {1}", followedCount.Value, types.ToString().ToLower());
        }
    }
}
"@ 

$type = Add-Type -ReferencedAssemblies $assem -TypeDefinition $source -Language CSharp  

[RefollowSites.Program]::Refollow()