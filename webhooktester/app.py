import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse

logger = logging.getLogger(__name__)
app = FastAPI()

WEBHOOKS = []


@app.get("/health-check")
def health_check():
    return {"status": "success"}


@app.post("/webhook")
async def webhook(request: Request):
    try:
        body = await request.json()
        logger.info("Received JSON webhook: %s. headers: %s", body, request.headers)
    except Exception:
        body = await request.body()
        logger.info("Received webhook: %s. headers: %s", body, request.headers)

    WEBHOOKS.append(body)

    return {"status": "success"}


@app.get("/webhooks")
async def get_webhook():
    return {"hooks": WEBHOOKS}


@app.exception_handler(404)
async def not_found_handler(request: Request, exc: HTTPException):
    logger.info(f"Not found: {request.method} {request.url}. headers: {request.headers}`n")
    return JSONResponse(status_code=404, content={"message": "Resource not found"})
