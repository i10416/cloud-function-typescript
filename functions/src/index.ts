import { Request, Response } from "express";
import { google } from "googleapis";

const sqlAdmin = google.sqladmin("v1beta4");

const setup = async () => {
  const auth = new google.auth.GoogleAuth({ scopes: [] });
  const authClient = await auth.getClient();
  google.options({ auth: authClient });
}

export const helloHTTPFunction = async (req: Request, res: Response) => {
  console.log(req);
  res.send();
};
/// See https://cloud.google.com/functions/docs/writing/background#function_parameters
/// cloud scheduler から PubSubJson に対応する json を payload として渡す
export const helloPubSubSubscriber = async (json: PubSubJson, context: PubSubContext) => {
  const data = Buffer.from(json.message.data, "base64").toString();
}