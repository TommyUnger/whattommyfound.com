import os
import logging
import logging.config

if not os.path.exists("logs"):
    os.makedirs("logs")

logging_config = {
    "version": 1,
    "formatters": {
        "detailed": {
            "format": "%(asctime)s %(name)26s %(funcName)18s %(levelname)6s %(message)s"
        }
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "level": "DEBUG",
            "formatter": "detailed",
        },
        "file": {
            "class": "logging.FileHandler",
            "level": "DEBUG",
            "formatter": "detailed",
            "filename": "logs/data_import.log",
            "mode": "a"
        }
    },
    "root": {
        "level": "DEBUG",
        "handlers": ["console", "file"]
    }
}

logging.config.dictConfig(logging_config)
