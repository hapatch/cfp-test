import os

DB = {
    "name": os.getenv("POSTGRES_DB", "postgres"),
    "user": os.getenv("POSTGRES_USER", "postgres"),
    "host": os.getenv("POSTGRES_HOST", "database"),
}
