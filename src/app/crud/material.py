from sqlalchemy.orm import Session
from model.material import Material
from fastapi import HTTPException

def list_materials(
        db: Session,
        supplier,
        name,
        general_type,
        specific_type) -> [Material]:
    m = db.query(Material)
    m = m.filter(Material.supplier == supplier) if supplier is not None else m
    m = m.filter(Material.name == name) if name is not None else m
    m = m.filter(Material.general_type == general_type) if general_type is not None else m
    m = m.filter(Material.specific_type == specific_type) if specific_type is not None else m
    return m.all()
