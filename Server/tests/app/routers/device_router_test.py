import io
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from app.dependencies.database import get_regular_db
from app.main import app
from app.entities.models import regular_db_base

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
regular_db_base.metadata.create_all(bind=engine)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_test_regular_db() -> Session:
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


# Dependency override
app.dependency_overrides[get_regular_db] = get_test_regular_db
client = TestClient(app)


# Helper function to create Minimal PNG image data (1x1 pixel, 8-bit color)
def create_minimal_png_image():
    png_data = (
        b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00'
        b'\x8d\x7d\xd0\x19\x00\x00\x00\x0cIDATx\xdac\x00\x00\x00\x01\x00\x01\x00\x00\x00\x00\x00'
        b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
        b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    )
    return io.BytesIO(png_data)


def get_token(is_admin: bool = False):
    username = "newadmin@example.com" if is_admin else "newuser@example.com"
    password = "adminpassword" if is_admin else "newpassword"
    response = client.post("/API/auth/token", data={"username": username, "password": password})
    response.raise_for_status()
    return response.json()["access_token"]


@pytest.fixture(scope="session")
def device_id():
    return test_create_device()


@pytest.mark.order(1)
def test_create_user():
    email = "newuser@example.com"
    password = "newpassword"
    response = client.post(
        "/API/users",
        json={"email": email, "password": password}
    )
    assert response.status_code == 200
    response_data = response.json()
    assert response_data["email"] == email


@pytest.mark.order(2)
def test_create_admin():
    email = "newadmin@example.com"
    password = "adminpassword"
    response = client.post(
        "/API/admins",
        json={"email": email, "password": password}
    )
    assert response.status_code == 200
    response_data = response.json()
    assert response_data["email"] == email


@pytest.mark.order(3)
def test_create_device():
    token = get_token(True)
    image_file = create_minimal_png_image()
    response = client.post(
        "/API/devices",
        headers={"Authorization": f"Bearer {token}"},
        files={"thumbnail": ("minimal.png", image_file, "image/png")},
        data={
            "title": "Test Device",
            "description": "Test Description",
            "type": "THERMO_HUMID_METER"
        }
    )
    assert response.status_code == 200
    assert response.headers["content-type"] == "image/png"
    return response.json().get("id")


@pytest.mark.order(4)
def test_read_all_unlinked_devices(device_id):
    token = get_token(True)
    response = client.get(
        "/API/devices/unlinked",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    assert isinstance(response.json(), list)


@pytest.mark.order(5)
def test_link_with_device(device_id):
    token = get_token()
    assert device_id is not None
    response = client.post(
        f"/API/devices/{device_id}/link",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    assert "id" in response.json()


@pytest.mark.order(6)
def test_read_all_user_devices(device_id):
    token = get_token()
    assert device_id is not None
    response = client.get(
        "/API/devices/me",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    assert isinstance(response.json(), list)


@pytest.mark.order(7)
def test_read_device(device_id):
    token = get_token()
    assert device_id is not None
    response = client.get(
        f"/API/devices/{device_id}",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    assert "id" in response.json()


@pytest.mark.order(8)
def test_update_device(device_id):
    token = get_token()
    assert device_id is not None
    response = client.put(
        f"/API/devices/{device_id}",
        headers={"Authorization": f"Bearer {token}"},
        json={"title": "Updated Device", "description": "Updated Description"}
    )
    assert response.status_code == 200
    assert response.json()["title"] == "Updated Device"


@pytest.mark.order(9)
def test_read_device_thumbnail(device_id):
    token = get_token()
    assert device_id is not None
    response = client.get(
        f"/API/devices/{device_id}/thumbnail",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    assert response.headers["content-type"] == "image/png"


@pytest.mark.order(10)
def test_toggle_device_state(device_id):
    token = get_token()
    assert device_id is not None
    response = client.post(
        f"/API/devices/{device_id}/toggle",
        headers={"Authorization": f"Bearer {token}"},
        params={"is_online": True}
    )
    assert response.status_code == 200
    assert response.json()["is_online"] is True
