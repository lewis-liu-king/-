from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from typing import Optional
from datetime import datetime

from app.database import get_db
from app.models import Component, ComponentModel, InstallationRecord, MaintenanceRecord, ScrapOrRetirementRecord
from app.schemas.component import ComponentCreate, ComponentUpdate, ComponentResponse, ComponentListResponse

router = APIRouter(prefix="/components", tags=["部件管理"])


@router.get("", response_model=ComponentListResponse)
def get_components(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    search: Optional[str] = None,
    status: Optional[str] = None,
    model_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Component)
    
    if search:
        query = query.filter(Component.component_serial.contains(search))
    
    if status:
        query = query.filter(Component.status == status)
    
    if model_id:
        query = query.filter(Component.model_id == model_id)
    
    total = query.count()
    items = query.offset((page - 1) * page_size).limit(page_size).all()
    
    return ComponentListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size
    )


@router.get("/{component_id}", response_model=ComponentResponse)
def get_component(component_id: int, db: Session = Depends(get_db)):
    component = db.query(Component).filter(Component.component_id == component_id).first()
    if not component:
        raise HTTPException(status_code=404, detail="部件不存在")
    return component


@router.post("", response_model=ComponentResponse, status_code=201)
def create_component(component: ComponentCreate, db: Session = Depends(get_db)):
    db_component = Component(**component.model_dump())
    db.add(db_component)
    try:
        db.commit()
        db.refresh(db_component)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=400, detail="创建失败，可能编号已存在")
    return db_component


@router.put("/{component_id}", response_model=ComponentResponse)
def update_component(component_id: int, component: ComponentUpdate, db: Session = Depends(get_db)):
    db_component = db.query(Component).filter(Component.component_id == component_id).first()
    if not db_component:
        raise HTTPException(status_code=404, detail="部件不存在")
    
    update_data = component.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_component, key, value)
    
    db.commit()
    db.refresh(db_component)
    return db_component


@router.delete("/{component_id}")
def delete_component(component_id: int, db: Session = Depends(get_db)):
    db_component = db.query(Component).filter(Component.component_id == component_id).first()
    if not db_component:
        raise HTTPException(status_code=404, detail="部件不存在")
    
    raise HTTPException(status_code=400, detail="不允许物理删除部件，请使用退役功能")


@router.post("/{component_id}/install", response_model=dict)
def install_component(
    component_id: int,
    aircraft_id: int,
    position: str,
    operator_id: Optional[int] = None,
    reason: Optional[str] = None,
    install_time: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    component = db.query(Component).filter(Component.component_id == component_id).first()
    if not component:
        raise HTTPException(status_code=404, detail="部件不存在")
    
    if component.is_retired:
        raise HTTPException(status_code=400, detail="部件已退役，无法安装")
    
    if component.status == "installed":
        raise HTTPException(status_code=400, detail="部件已安装在其他飞机上")
    
    active_install = db.query(InstallationRecord).filter(
        InstallationRecord.component_id == component_id,
        InstallationRecord.removal_time.is_(None)
    ).first()
    
    if active_install:
        raise HTTPException(status_code=400, detail="部件已有有效安装记录")
    
    installation = InstallationRecord(
        component_id=component_id,
        aircraft_id=aircraft_id,
        installation_position=position,
        installation_reason=reason,
        installation_operator_id=operator_id,
        installation_time=install_time or datetime.now()
    )
    
    component.status = "installed"
    db.add(installation)
    db.commit()
    
    return {"message": "部件安装成功"}


@router.post("/{component_id}/remove", response_model=dict)
def remove_component(
    component_id: int,
    removal_reason: str,
    operator_id: Optional[int] = None,
    removal_time: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    component = db.query(Component).filter(Component.component_id == component_id).first()
    if not component:
        raise HTTPException(status_code=404, detail="部件不存在")
    
    active_install = db.query(InstallationRecord).filter(
        InstallationRecord.component_id == component_id,
        InstallationRecord.removal_time.is_(None)
    ).first()
    
    if not active_install:
        raise HTTPException(status_code=400, detail="部件未安装")
    
    active_install.removal_time = removal_time or datetime.now()
    active_install.removal_reason = removal_reason
    active_install.removal_operator_id = operator_id
    
    component.status = "available"
    db.commit()
    
    return {"message": "部件拆卸成功"}


@router.post("/replace", response_model=dict)
def replace_component(
    old_component_id: int,
    new_component_id: int,
    aircraft_id: int,
    position: str,
    removal_reason: str,
    installation_reason: Optional[str] = None,
    operator_id: Optional[int] = None,
    removal_time: Optional[datetime] = None,
    installation_time: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    old_component = db.query(Component).filter(Component.component_id == old_component_id).first()
    new_component = db.query(Component).filter(Component.component_id == new_component_id).first()
    
    if not old_component or not new_component:
        raise HTTPException(status_code=404, detail="部件不存在")
    
    active_install = db.query(InstallationRecord).filter(
        InstallationRecord.component_id == old_component_id,
        InstallationRecord.aircraft_id == aircraft_id,
        InstallationRecord.removal_time.is_(None)
    ).first()
    
    if not active_install:
        raise HTTPException(status_code=400, detail="旧部件未安装在指定飞机上")
    
    if new_component.is_retired:
        raise HTTPException(status_code=400, detail="新部件已退役")
    
    new_active_install = db.query(InstallationRecord).filter(
        InstallationRecord.component_id == new_component_id,
        InstallationRecord.removal_time.is_(None)
    ).first()
    
    if new_active_install:
        raise HTTPException(status_code=400, detail="新部件已安装在其他飞机上")
    
    active_install.removal_time = removal_time or datetime.now()
    active_install.removal_reason = removal_reason
    active_install.removal_operator_id = operator_id
    
    old_component.status = "available"
    
    new_installation = InstallationRecord(
        component_id=new_component_id,
        aircraft_id=aircraft_id,
        installation_position=position,
        installation_reason=installation_reason,
        installation_operator_id=operator_id,
        installation_time=installation_time or datetime.now()
    )
    
    new_component.status = "installed"
    
    db.add(new_installation)
    db.commit()
    
    return {"message": "部件更换成功"}


@router.post("/{component_id}/retire", response_model=dict)
def retire_component(
    component_id: int,
    retirement_reason: str,
    operator_id: Optional[int] = None,
    notes: Optional[str] = None,
    retirement_time: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    component = db.query(Component).filter(Component.component_id == component_id).first()
    if not component:
        raise HTTPException(status_code=404, detail="部件不存在")
    
    active_install = db.query(InstallationRecord).filter(
        InstallationRecord.component_id == component_id,
        InstallationRecord.removal_time.is_(None)
    ).first()
    
    if active_install:
        raise HTTPException(status_code=400, detail="部件仍在安装中，请先拆卸")
    
    existing_retirement = db.query(ScrapOrRetirementRecord).filter(
        ScrapOrRetirementRecord.component_id == component_id
    ).first()
    
    if existing_retirement:
        raise HTTPException(status_code=400, detail="部件已退役")
    
    retirement = ScrapOrRetirementRecord(
        component_id=component_id,
        retirement_reason=retirement_reason,
        approval_operator_id=operator_id,
        retirement_time=retirement_time or datetime.now(),
        notes=notes
    )
    
    component.is_retired = True
    component.status = "retired"
    
    db.add(retirement)
    db.commit()
    
    return {"message": "部件退役成功"}


@router.get("/{component_id}/lifecycle", response_model=dict)
def get_component_lifecycle(component_id: int, db: Session = Depends(get_db)):
    component = db.query(Component).filter(Component.component_id == component_id).first()
    if not component:
        raise HTTPException(status_code=404, detail="部件不存在")
    
    model = db.query(ComponentModel).filter(ComponentModel.model_id == component.model_id).first()
    
    installations = db.query(InstallationRecord).filter(
        InstallationRecord.component_id == component_id
    ).order_by(InstallationRecord.installation_time.desc()).all()
    
    maintenances = db.query(MaintenanceRecord).filter(
        MaintenanceRecord.component_id == component_id
    ).order_by(MaintenanceRecord.start_time.desc()).all()
    
    retirement = db.query(ScrapOrRetirementRecord).filter(
        ScrapOrRetirementRecord.component_id == component_id
    ).first()
    
    installation_list = []
    for inst in installations:
        installation_list.append({
            "installation_id": inst.installation_id,
            "aircraft_id": inst.aircraft_id,
            "position": inst.installation_position,
            "reason": inst.installation_reason,
            "install_time": inst.installation_time,
            "removal_reason": inst.removal_reason,
            "removal_time": inst.removal_time,
            "is_active": inst.removal_time is None
        })
    
    maintenance_list = []
    for maint in maintenances:
        maintenance_list.append({
            "maintenance_id": maint.maintenance_id,
            "work_order": maint.work_order_number,
            "type": maint.maintenance_type,
            "description": maint.description,
            "start_time": maint.start_time,
            "end_time": maint.end_time,
            "result": maint.result,
            "notes": maint.notes
        })
    
    return {
        "component_id": component.component_id,
        "component_serial": component.component_serial,
        "model_code": model.model_code if model else None,
        "category": model.category if model else None,
        "status": component.status,
        "is_retired": component.is_retired,
        "total_usage_hours": float(component.total_usage_hours) if component.total_usage_hours else 0,
        "received_time": component.created_at,
        "installations": installation_list,
        "maintenances": maintenance_list,
        "retirement": {
            "reason": retirement.retirement_reason,
            "time": retirement.retirement_time,
            "notes": retirement.notes
        } if retirement else None
    }
