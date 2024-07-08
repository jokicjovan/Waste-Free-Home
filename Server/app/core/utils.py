import re

import qrcode


def generate_qr_code(data: str):
    qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_L, box_size=10, border=4)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill="black", back_color="white")
    return img


def camelcase_to_snakecase(name):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()
