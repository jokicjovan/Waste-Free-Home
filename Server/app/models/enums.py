from enum import Enum


class Role(str, Enum):
    ADMIN = "ADMIN"
    USER = "USER"


class DeviceType(str, Enum):
    THERMOMETER = "THERMOMETER"
    WASTE_SORTER = "WASTE_SORTER"
