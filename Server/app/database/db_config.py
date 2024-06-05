import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

load_dotenv()

POSTGRES_DATABASE_USER = os.getenv("POSTGRES_DATABASE_USER")
POSTGRES_DATABASE_PASSWORD = os.getenv("POSTGRES_DATABASE_PASSWORD")
POSTGRES_DATABASE_HOST = os.getenv("POSTGRES_DATABASE_HOST")
POSTGRES_DATABASE_PORT = os.getenv("POSTGRES_DATABASE_PORT")
POSTGRES_DATABASE_NAME = os.getenv("POSTGRES_DATABASE_NAME")

SQLALCHEMY_POSTGRES_DATABASE_URL = (
    f"postgresql://{POSTGRES_DATABASE_USER}:{POSTGRES_DATABASE_PASSWORD}@{POSTGRES_DATABASE_HOST}:"
    f"{POSTGRES_DATABASE_PORT}/{POSTGRES_DATABASE_NAME}"
)

postgres_engine = create_engine(SQLALCHEMY_POSTGRES_DATABASE_URL)
postgres_session_local = sessionmaker(autocommit=False, autoflush=False, bind=postgres_engine)
Base = declarative_base()


def get_postgres_db():
    db = postgres_session_local()
    try:
        yield db
    finally:
        db.close()
