from importlib.metadata import PackageNotFoundError, version

__author__ = """Quali"""
try:
    __version__ = version("webhooktester")
except PackageNotFoundError:
    __version__ = "0.1.0"
