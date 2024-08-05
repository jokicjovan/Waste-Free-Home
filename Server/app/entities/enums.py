from enum import Enum


class Role(str, Enum):
    ADMIN = "ADMIN"
    REGULAR_USER = "REGULAR_USER"


class DeviceType(str, Enum):
    THERMO_HUMID_METER = "THERMO_HUMID_METER"
    WASTE_SORTER = "WASTE_SORTER"


class WasteType(str, Enum):
    RECYCLABLE = "RECYCLABLE"
    NON_RECYCLABLE = "NON_RECYCLABLE"
