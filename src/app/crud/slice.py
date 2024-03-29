from sqlalchemy.orm import Session
from typing import List
from model.slice import Slice
from model.slice_specification import SliceSpecification
from model.cura_parameter import CuraParameter
from schema.slice_specification import CuraParameterIn
from schema.slice import SliceIn
from fastapi import HTTPException
import logging

def list_slices(db: Session, username: str) -> [Slice]:
    u = db.query(User).filter(User.username == username).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    if u.superuser:
        return db.query(Slice).all()
    grps = db.query(Group).join(UserGroup).filter(UserGroup.user_id == u.id).all()
    g_ids = [g.id for g in grps]
    perm_read_user = db.query(PermissionPart).filter(PermissionPart.user_id == u.id).all()
    perm_read_users_group = db.query(PermissionPart).filter(PermissionPart.group_id.in_(g_ids)).all()
    parts_id = [p.part_id for p in perm_read_user]
    parts_id += [p.part_id for p in perm_read_users_group]
    if not len(parts_id):
        return None
    s = db.query(Slice).filter(Slice.part_id.in_(parts_id)).all()
    return s

def get_slice(db: Session, id_slice: int) -> Slice:
    s = db.query(Slice).filter(Slice.id == id_slice).first()
    if s is None:
        raise HTTPException(status_code=404, detail="Slice not found")
    return s

def create_cura_parameter(
        db: Session,
        cura_params: List[CuraParameterIn],
        slicer_spec_id: int):

    if cura_params is None:
        return None
    for cp in cura_params:
        cp = CuraParameter(**{
            'slicer_spec_id': slicer_spec_id,
            'no_extruder': cp.no_extruder,
            'key': cp.key,
            'value': cp.value
        })
        db.add(cp)
    db.commit()
    db.refresh(cp)

def create_slice(db: Session, s_in: SliceIn) -> Slice:
    # TODO try catch pour les bon message d'erreur
    # Insert slice specification
    sp = s_in.dict()['slice_spec']
    sp = {
        'cura_definition_file_e0': sp['cura_definition_file_e0'],
        'cura_definition_file_e1': sp['cura_definition_file_e1']
    }
    sp = SliceSpecification(**sp)
    db.add(sp)
    db.commit()
    db.refresh(sp)
    # Insert cura parameter
    print(s_in)
    create_cura_parameter(db, s_in.slice_spec.cura_parameters, sp.id)
    # Insert slice
    slice = s_in.dict().copy()
    u = {'slice_spec_id': sp.id}
    slice.pop('slice_spec')
    slice.update(u)
    s = Slice(**slice)
    db.add(s)
    db.commit()
    db.refresh(s)
    return s
