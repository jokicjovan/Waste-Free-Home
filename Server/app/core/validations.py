from fastapi import UploadFile, File, HTTPException
from typing import Optional
import mimetypes


async def validate_thumbnail(thumbnail: Optional[UploadFile] = File(None)):
    if thumbnail is not None:
        contents = await thumbnail.read()

        # Check file size
        if len(contents) > 1 * 1024 * 1024:  # 1MB
            raise HTTPException(status_code=400, detail="Image size should not exceed 1MB")

        # Reset the file pointer to the beginning
        thumbnail.file.seek(0)

        # Guess MIME type
        mime_type, _ = mimetypes.guess_type(thumbnail.filename)
        if mime_type not in ['image/jpeg', 'image/png', 'image/gif', 'image/bmp']:
            raise HTTPException(status_code=400, detail="Unsupported image format")

    return thumbnail
