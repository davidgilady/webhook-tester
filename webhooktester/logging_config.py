import json
import logging
import os

import colorlog

LOG_COLORS = {
    "DEBUG": "cyan",
    "INFO": "green",
    "WARNING": "yellow",
    "ERROR": "red",
    "CRITICAL": "red,bg_white",
}


class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "level": record.levelname,
            "message": record.getMessage(),
            "time": self.formatTime(record, self.datefmt),
            "name": record.name,
            "filename": record.filename,
            "lineno": record.lineno,
        }
        if record.exc_info:
            log_record["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_record)


def configure_logging():
    json_logging = os.environ.get("JSON_LOGGING", False)
    if json_logging:
        logHandler = logging.StreamHandler()
        formatter = JsonFormatter()
        logHandler.setFormatter(formatter)
    else:
        log_format = (
            "%(log_color)s%(levelname)-8s%(reset)s[%(cyan)s%(asctime)s%(reset)s] "
            "%(blue)s%(name)s%(reset)s - %(message)s"
        )
        logHandler = colorlog.StreamHandler()
        formatter = colorlog.ColoredFormatter(log_format, log_colors=LOG_COLORS)
        logHandler.setFormatter(formatter)

    logging.basicConfig(level=logging.INFO, handlers=[logHandler])
