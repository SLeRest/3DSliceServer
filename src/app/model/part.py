#from core.database import Base
from core.settings import settings
from model.base import BaseModel
from schema.part import PartOut
from sqlalchemy import (
    Column,
    BigInteger,
    String,
    Float,
    LargeBinary
)

class Part(BaseModel):
    __tablename__ = 'PART'

    name = Column('NAME', String, nullable=False)
    unit = Column('UNIT', String, nullable=False)
    file = Column('FILE', LargeBinary, default=None)
    file_size = Column('FILE_SIZE', BigInteger, default=None)
    format = Column('FORMAT', String, nullable=False)
    volume = Column('VOLUME', Float, default=None)
    volume_support = Column('VOLUME_SUPPORT', Float, default=None)
    x = Column('X', Float, default=None)
    y = Column('Y', Float, default=None)
    z = Column('Z', Float, default=None)

    def __init__(self, name, unit, format):
        self.name = name
        self.unit = unit
        self.format = format

    def ToPartOut(self) -> PartOut:
        return PartOut(
            id = self.id,
            name = self.name,
            unit = self.unit,
            file_size = self.file_size,
            volume = self.volume,
            volume_support = self.volume_support,
            format = self.format,
            x = self.x,
            y = self.y,
            z = self.z,
            created_at = self.created_at,
            updated_at = self.updated_at
        )
