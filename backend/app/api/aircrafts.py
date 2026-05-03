from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Optional
from datetime import datetime

from app.database import get_db
from app.models import Aircraft
from app.schemas.aircraft import AircraftCreate, AircraftUpdate, AircraftResponse, AircraftListResponse

router = APIRouter(prefix="/aircrafts", tags=["飞机管理"])


@router.get("", response_model=AircraftListResponse)
def get_aircrafts(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    search: Optional[str] = None,
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Aircraft)
    
    if search:
        query = query.filter(
            (Aircraft.aircraft_number.contains(search)) |
            (Aircraft.model.contains(search))
        )
    
    if status:
        query = query.filter(Aircraft.status == status)
    
    total = query.count()
    items = query.offset((page - 1) * page_size).limit(page_size).all()
    
    return AircraftListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size
    )


@router.get("/{aircraft_id}", response_model=AircraftResponse)
def get_aircraft(aircraft_id: int, db: Session = Depends(get_db)):
    aircraft = db.query(Aircraft).filter(Aircraft.aircraft_id == aircraft_id).first()
    if not aircraft:
        raise HTTPException(status_code=404, detail="飞机不存在")
    return aircraft


@router.post("", response_model=AircraftResponse, status_code=201)
def create_aircraft(aircraft: AircraftCreate, db: Session = Depends(get_db)):
    db_aircraft = Aircraft(**aircraft.model_dump())
    db.add(db_aircraft)
    try:
        db.commit()
        db.refresh(db_aircraft)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=400, detail="创建失败，可能编号已存在")
    return db_aircraft


@router.put("/{aircraft_id}", response_model=AircraftResponse)
def update_aircraft(aircraft_id: int, aircraft: AircraftUpdate, db: Session = Depends(get_db)):
    db_aircraft = db.query(Aircraft).filter(Aircraft.aircraft_id == aircraft_id).first()
    if not db_aircraft:
        raise HTTPException(status_code=404, detail="飞机不存在")
    
    update_data = aircraft.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_aircraft, key, value)
    
    db.commit()
    db.refresh(db_aircraft)
    return db_aircraft


@router.delete("/{aircraft_id}")
def delete_aircraft(aircraft_id: int, db: Session = Depends(get_db)):
    db_aircraft = db.query(Aircraft).filter(Aircraft.aircraft_id == aircraft_id).first()
    if not db_aircraft:
        raise HTTPException(status_code=404, detail="飞机不存在")
    
    db_aircraft.status = "inactive"
    db.commit()
    return {"message": "飞机已停用"}
