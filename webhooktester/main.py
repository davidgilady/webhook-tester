import os

import uvicorn

from webhooktester.app import app
from webhooktester.logging_config import configure_logging


def main() -> None:
    configure_logging()

    host = os.environ.get("WEBHOOK_HOST", "0.0.0.0")
    port = int(os.environ.get("WEBHOOK_PORT", 8000))

    access_log = bool(os.environ.get("ACCESS_LOG", False))
    uvicorn.run(app, host=host, port=port, workers=1, log_config=None, access_log=access_log)


if __name__ == "__main__":
    main()
