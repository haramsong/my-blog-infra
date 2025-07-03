const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient } = require("@aws-sdk/lib-dynamodb");
const { GetCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const db = DynamoDBDocumentClient.from(client);
const TABLE = process.env.TABLE_NAME;

exports.handler = async (event) => {
  const origin = event.headers.origin;
  const method = event.requestContext.http.method;

  if (method === "OPTIONS") {
    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": origin,
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type,x-api-token",
        "Access-Control-Max-Age": "3600",
      },
      body: JSON.stringify({ message: "CORS preflight passed" })
    };
  }

  const slug = event.queryStringParameters?.slug || JSON.parse(event.body || "{}").slug;
  if (!slug) {
    return response(400, { message: "Missing slug" }, origin);
  }

  const SECRET = process.env.API_SECRET;
  const reqToken = event.headers["x-api-token"];
  if (reqToken !== SECRET) {
    return response(401, { message: "Unauthorized" }, origin);
  }

  if (method === "GET") {
    const result = await db.send(new GetCommand({
      TableName: TABLE,
      Key: { slug }
    }));

    return response(200, { views: result.Item?.views || 0 }, origin);
  }

  if (method === "POST") {
    const updated = await db.send(new UpdateCommand({
      TableName: TABLE,
      Key: { slug },
      UpdateExpression: "ADD #v :incr",
      ExpressionAttributeNames: { "#v": "views" },
      ExpressionAttributeValues: { ":incr": 1 },
      ReturnValues: "UPDATED_NEW"
    }));

    return response(200, { views: updated.Attributes.views }, origin);
  }

  return response(405, { message: "Method not allowed" });
};

function response(statusCode, body, origin = "") {
  const allowedOrigins = [
    "https://blog.hrsong.com",
    "http://localhost:3000",
  ];

  return {
    statusCode,
    headers: {
      "Access-Control-Allow-Origin": allowedOrigins.includes(origin)
        ? origin
        : "https://blog.hrsong.com",
      "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type,x-api-token"
    },
    body: JSON.stringify(body)
  };
}
