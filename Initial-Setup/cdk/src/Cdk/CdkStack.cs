using Amazon.CDK;
using Amazon.CDK.AWS.Lambda;
using Constructs;

namespace Cdk
{
    public class CdkStack : Stack
    {
        internal CdkStack(Construct scope, string id, IStackProps props = null) : base(scope, id, props)
        {
            // Publish output of the HelloLambda project; run `dotnet publish -c Release`
            // (or .\deploy.ps1) before synth/deploy so this folder exists.
            var helloFunction = new Function(this, "HelloFunction", new FunctionProps
            {
                Runtime = Runtime.DOTNET_8,
                Handler = "HelloLambda::HelloLambda.Function::FunctionHandler",
                Code = Code.FromAsset("src/HelloLambda/bin/Release/net8.0/publish"),
                MemorySize = 256,
                Timeout = Duration.Seconds(10),
                Description = "Hello/echo starter Lambda exposed via a Function URL",
            });

            // Public URL: anyone with the link can call it (hello-world only).
            var functionUrl = helloFunction.AddFunctionUrl(new FunctionUrlOptions
            {
                AuthType = FunctionUrlAuthType.NONE,
            });

            new CfnOutput(this, "HelloFunctionUrl", new CfnOutputProps
            {
                Value = functionUrl.Url,
                Description = "Public URL of the hello Lambda",
            });
        }
    }
}
