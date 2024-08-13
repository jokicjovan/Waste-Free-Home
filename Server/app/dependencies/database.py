from sqlalchemy.orm import Session

from app.core.database_manager import regular_db_manager, time_series_db_manager


def get_regular_db() -> Session:
    db = regular_db_manager.get_session()
    try:
        yield db
    finally:
        db.close()


def get_time_series_db() -> Session:
    db = time_series_db_manager.get_session()
    try:
        yield db
    finally:
        db.close()
