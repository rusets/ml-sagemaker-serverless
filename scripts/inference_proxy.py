import os, json, base64, boto3

R = os.environ.get("REGION", "us-east-1")
EP = os.environ["ENDPOINT_NAME"]
CT = "application/json"
AC = "application/json"

sm = boto3.client("sagemaker-runtime", region_name=R)

def _resp(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST,OPTIONS",
            "Access-Control-Allow-Headers": "content-type,authorization"
        },
        "body": json.dumps(body)
    }

def lambda_handler(event, ctx):
    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return _resp(200, {"ok": True})
    try:
        body_raw = event.get("body") or "{}"
        if event.get("isBase64Encoded"):
            body_raw = base64.b64decode(body_raw).decode("utf-8")
        resp = sm.invoke_endpoint(
            EndpointName=EP,
            Body=body_raw.encode("utf-8"),
            ContentType=CT,
            Accept=AC
        )
        out = resp["Body"].read().decode("utf-8")
        try:
            return _resp(200, json.loads(out))
        except Exception:
            return _resp(200, {"raw": out})
    except Exception as e:
        return _resp(500, {"error": str(e)})
