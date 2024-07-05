from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.entities.time_series_models import timescale_base

TIMESCALE_DATABASE_URL = (
    f"postgresql://{settings.timescale_user}:{settings.timescale_password}@"
    f"{settings.timescale_host}:{settings.timescale_port}/{settings.timescale_name}"
)
timescale_engine = create_engine(TIMESCALE_DATABASE_URL)
timescale_session_local = sessionmaker(autocommit=False, bind=timescale_engine)
timescale_base.metadata.create_all(bind=timescale_engine)


def get_timescale_db():
    db = timescale_session_local()
    try:
        yield db
    finally:
        db.close()
