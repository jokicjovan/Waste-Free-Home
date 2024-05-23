from threading import Timer
from datetime import timedelta
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import Depends, FastAPI, HTTPException, status

from app.utils.config import settings
from app.auth.password import get_password_hash, verify_password
from app.auth.token import get_current_user, create_access_token
from app.models.token import Token
from app.models.user import User, UserInDB

app = FastAPI()

# Fake database
fake_users_db = {
    "user@example.com": {
        "username": "user@example.com",
        "full_name": "John Doe",
        "hashed_password": get_password_hash("password123"),
        "disabled": False,
    }
}


def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)


def authenticate_user(fake_db, username: str, password: str):
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(fake_users_db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/users/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user


@app.on_event("startup")
async def startup_event():
    import webbrowser

    def open_swagger_ui():
        webbrowser.open_new("http://127.0.0.1:8000/docs")

    Timer(1, open_swagger_ui).start()
