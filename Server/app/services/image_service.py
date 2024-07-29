import os
import uuid

from fastapi import UploadFile

from app.core.config import settings


async def save_device_thumbnail(device_id: uuid.UUID, image: UploadFile):
    current_directory = os.getcwd()
    thumbnails_directory = os.path.join(current_directory, settings.devices_thumbnails_path)
    os.makedirs(thumbnails_directory, exist_ok=True)

    image_content = await image.read()
    image_path = os.path.join(thumbnails_directory, f"{device_id}.png")

    with open(image_path, "wb") as f:
        f.write(image_content)

    return image_path


def get_device_thumbnail_path(device_id: uuid.UUID) -> str:
    current_directory = os.getcwd()
    thumbnails_directory = os.path.join(current_directory, settings.devices_thumbnails_path)
    image_path = os.path.join(thumbnails_directory, f"{device_id}.png")
    return image_path
