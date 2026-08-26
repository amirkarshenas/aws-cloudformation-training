using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;

// Tells Lambda how to convert the incoming JSON event into the request object below.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace HelloLambda;

public class Function
{
    // Function URLs deliver requests in the same shape as API Gateway HTTP API v2 payloads.
    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request, ILambdaContext context)
    {
        var name = "world x";
        if (request.QueryStringParameters is { } query &&
            query.TryGetValue("name", out var value) &&
            !string.IsNullOrWhiteSpace(value))
        {
            name = value;
        }

        var body = new
        {
            message = $"Hello, {name}!",
            youSent = new
            {
                method = request.RequestContext?.Http?.Method,
                path = request.RawPath,
                queryString = request.RawQueryString,
            },
            handledBy = context.FunctionName,
            atUtc = DateTime.UtcNow,
        };

        return new APIGatewayHttpApiV2ProxyResponse
        {
            StatusCode = 200,
            Headers = new Dictionary<string, string> { ["Content-Type"] = "application/json" },
            Body = JsonSerializer.Serialize(body),
        };
    }
}
