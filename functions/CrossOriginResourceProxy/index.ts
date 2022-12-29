import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import fetch, { Headers, RequestInit } from "node-fetch";
import { env } from "process";

const PassThroughHeaders: RegExp[] = [
  /Authorization/i,
  /content-type/i,
  /^X-.+/i,
];

const isThroughHeader = (key: string): boolean =>
  PassThroughHeaders.some((re) => re.test(key));

const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  const pathInfo = [
    context.bindingData.p1,
    context.bindingData.p2,
    context.bindingData.p3,
    context.bindingData.p4,
  ].filter((x) => x);

  const url = env["URL"] + pathInfo.join("/");
  const headers = new Headers();

  Object.keys(req.headers)
    .filter(isThroughHeader)
    .forEach((key) => {
      headers.set(key, req.headers[key]);
    });

  const init: RequestInit = {
    body: req.body,
    method: req.method ?? undefined,
    headers: headers,
  };

  try {
    const res = await fetch(url, init);
    const text = await res.text();

    context.res = {
      body: JSON.parse(text),
    };
  } catch (ex) {
    context.log.error(ex);
  }
};

export default httpTrigger;
