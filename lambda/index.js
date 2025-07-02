const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();
const TABLE = process.env.TABLE_NAME;

exports.handler = async (event) => {
  const slug = event.queryStringParameters?.slug || JSON.parse(event.body || "{}").slug;
  if (!slug) {
    return response(400, { message: "Missing slug" });
  }

  const method = event.requestContext.http.method;
  if (method === "GET") {
    const result = await db.get({ TableName: TABLE, Key: { slug } }).promise();
    return response(200, { views: result.Item?.views || 0 });
  }

  if (method === "POST") {
    const updated = await db.update({
      TableName: TABLE,
      Key: { slug },
      UpdateExpression: "ADD views :incr",
      ExpressionAttributeValues: { ":incr": 1 },
      ReturnValues: "UPDATED_NEW"
    }).promise();
    return response(200, { views: updated.Attributes.views });
  }

  return response(405, { message: "Method not allowed" });
};

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "Access-Control-Allow-Origin": "https://blog.hrsong.com",
      "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    },
    body: JSON.stringify(body)
  };
}
