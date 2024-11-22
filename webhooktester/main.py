import uvicorn

from webhooktester.app import app
from webhooktester.logging_config import configure_logging


def main() -> None:
    configure_logging()
    uvicorn.run(app, host="127.0.0.1", port=8000, workers=1, log_config=None)


if __name__ == "__main__":
    main()
