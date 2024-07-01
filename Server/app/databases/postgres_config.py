from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from app.core.server_config import settings

SQLALCHEMY_POSTGRES_DATABASE_URL = (
    f"postgresql://{settings.postgres_user}:{settings.postgres_password}@"
    f"{settings.postgres_host}:{settings.postgres_port}/{settings.postgres_name}"
)

postgres_engine = create_engine(SQLALCHEMY_POSTGRES_DATABASE_URL)
postgres_session_local = sessionmaker(autocommit=False, bind=postgres_engine)
Base = declarative_base()


def get_postgres_db():
    db = postgres_session_local()
    try:
        yield db
    finally:
        db.close()
