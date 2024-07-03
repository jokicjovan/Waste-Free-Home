from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.entities.models import postgres_base

POSTGRES_DATABASE_URL = (
    f"postgresql://{settings.postgres_user}:{settings.postgres_password}@"
    f"{settings.postgres_host}:{settings.postgres_port}/{settings.postgres_name}"
)

postgres_engine = create_engine(POSTGRES_DATABASE_URL)
postgres_session_local = sessionmaker(autocommit=False, bind=postgres_engine)
postgres_base.metadata.create_all(bind=postgres_engine)


def get_postgres_db():
    db = postgres_session_local()
    try:
        yield db
    finally:
        db.close()
