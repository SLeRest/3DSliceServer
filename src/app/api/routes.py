from fastapi import APIRouter
from api.slice import router as router_slice
from api.part import router as router_part
from api.user import router as router_user

router = APIRouter()
router.include_router(router_slice, tags=["slices"], prefix="/slices")
router.include_router(router_part, tags=["parts"], prefix="/parts")
router.include_router(router_user, tags=["users"], prefix="/users")
#router.include_router(material.router, tags=["material"], prefix="/materials")
#router.include_router(machine.router, tags=["machine"], prefix="/machines")
