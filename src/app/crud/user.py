from schema.user import UserLogin, UserIn, UserPatch
from model.user import User
from model.permission import Permission
from model.group import Group
from model.user_group import UserGroup
from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import Tuple
import hashlib

def login(user: UserLogin, db: Session) -> bool:
    u = db.query(User).filter(User.username == user.username).first()
    # username not exist
    if u is None:
        return False
    hash_password = hashlib.sha256(user.password.encode()).hexdigest()
    if u.password == hash_password:
        return True
    return False

def list_users(db: Session) -> [User]:
    u = db.query(User).all()
    return u

def create_user(u_in: UserIn, db: Session) -> User:
    u = User(**u_in.dict())
    u.password = hashlib.sha256(u.password.encode()).hexdigest()
    db.add(u)
    db.commit()
    db.refresh(u)
    return u

def get_user(id_user: int, db: Session) -> User:
    u = db.query(User).filter(User.id == id_user).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    return u

def get_user_by_username(username: str, db: Session) -> User:
    u = db.query(User).filter(User.username == username).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    return u

def get_user_by_email(email: str, db: Session) -> User:
    u = db.query(User).filter(User.email == email).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    return u

def list_groups_of_user(id_user: int, db: Session) -> [Group]:
    g = db.query(Group).join(UserGroup).filter(UserGroup.user_id == id_user).all()
    return g

def list_user_permissions(id_user: int, db: Session) -> [Permission]:
    p = db.query(Permission).filter(Permission.user_id == id_user).all()
    return p

def check_superuser(db: Session, username: str) -> bool:
    u = db.query(User).filter(User.username == username).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    if u.superuser:
        return True
    return False

def check_read_user(db: Session, username: str, id_user: int) -> bool:
    u = db.query(User).filter(User.username == username).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    if u.superuser or u.id == id_user:
        return True
    return False

def check_modify_user(db: Session, username: str, id_user: int) -> Tuple[bool, bool]:
    superuser, check_user = False, False
    u = db.query(User).filter(User.username == username).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    if u.superuser:
        superuser = True
    if u.id == id_user:
        check_user = True
    return superuser, check_user

def patch_user(db: Session, user: UserPatch, id_user: int) -> User:
    u = db.query(User).filter(User.id == id_user).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    for var, value in vars(user).items():
        if var == 'password':
            u.password = hashlib.sha256(u.password.encode()).hexdigest()
        else:
            setattr(u, var, value) if value else None
    db.add(u)
    db.commit()
    db.refresh(u)
    return u

def delete_user(db: Session, id_user: int):
    u = db.query(User).filter(User.id == id_user).first()
    if u is None:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(u)
    db.commit()
