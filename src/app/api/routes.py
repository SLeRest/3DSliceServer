from fastapi import APIRouter
from api.slice import router as router_slice
from api.part import router as router_part

router = APIRouter()
router.include_router(router_slice, tags=["slices"], prefix="/slices")
router.include_router(router_part, tags=["parts"], prefix="/parts")
#router.include_router(material.router, tags=["material"], prefix="/materials")
#router.include_router(machine.router, tags=["machine"], prefix="/machines")
