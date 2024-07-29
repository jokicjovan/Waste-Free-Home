from typing import Optional
from fastapi import UploadFile, File, HTTPException


async def verify_thumbnail_size(thumbnail: Optional[UploadFile] = File(None)):
    if thumbnail:
        contents = await thumbnail.read()
        if len(contents) > 1 * 1024 * 1024:  # 1MB
            raise HTTPException(status_code=400, detail="Image size should not exceed 1MB")
        thumbnail.file.seek(0)  # Reset the file pointer to the beginning
    return thumbnail
