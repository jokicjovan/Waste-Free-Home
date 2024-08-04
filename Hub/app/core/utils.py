import httpx

from app.core.config import settings


def update_env_file(key, value):
    # Path to the .env file
    env_file_path = '.env'

    # Read the current content of the .env file
    with open(env_file_path, 'r') as f:
        lines = f.readlines()

    # Find and update the specific key-value pair
    updated_lines = []
    for line in lines:
        if line.startswith(f"{key}="):
            updated_lines.append(f"{key}={value}\n")
        else:
            updated_lines.append(line)

    # Write the updated content back to the .env file
    with open(env_file_path, 'w') as f:
        f.writelines(updated_lines)


def get_jwt():
    url = f"http://{settings.server_hostname}:{settings.server_port}/{settings.server_auth_endpoint}"
    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }
    form = {"username": settings.user_email, "password": settings.user_password}
    try:
        with httpx.Client() as client:
            response = client.post(url, headers=headers, data=form)
            response.raise_for_status()
            print(f"Response status code: {response.status_code}")

            if response.status_code == 200:
                settings.jwt = response.json()["access_token"]

    except httpx.HTTPStatusError as e:
        print(f"HTTP error occurred: {e}")
    except httpx.RequestError as e:
        print(f"Request error occurred: {e}")