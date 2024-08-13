from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.entities.models import regular_db_base
from app.entities.time_series_models import time_series_db_base


class DatabaseManager:
    def __init__(self, database_url, models):
        self.engine = create_engine(database_url)
        self.SessionLocal = sessionmaker(autocommit=False, bind=self.engine)
        models.metadata.create_all(bind=self.engine)

    def get_session(self):
        return self.SessionLocal()


regular_db_manager = DatabaseManager(settings.regular_database_url, regular_db_base)
time_series_db_manager = DatabaseManager(settings.time_series_database_url, time_series_db_base)
