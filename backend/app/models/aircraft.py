from sqlalchemy import Column, Integer, String, Date, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Aircraft(Base):
    __tablename__ = "aircrafts"
    
    aircraft_id = Column(Integer, primary_key=True, autoincrement=True)
    aircraft_number = Column(String(50), nullable=False, unique=True)
    model = Column(String(100), nullable=False)
    status = Column(String(20), nullable=False, default="active")
    commission_date = Column(Date)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    installations = relationship("InstallationRecord", back_populates="aircraft")
    flights = relationship("FlightLog", back_populates="aircraft")
