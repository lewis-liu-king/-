from sqlalchemy import Column, Integer, String, DateTime, DECIMAL, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class FlightLog(Base):
    __tablename__ = "flight_logs"
    
    flight_id = Column(Integer, primary_key=True, autoincrement=True)
    aircraft_id = Column(Integer, ForeignKey("aircrafts.aircraft_id"), nullable=False)
    flight_number = Column(String(50))
    mission_type = Column(String(50), nullable=False)
    departure_airport = Column(String(100))
    arrival_airport = Column(String(100))
    takeoff_time = Column(DateTime, nullable=False)
    landing_time = Column(DateTime)
    flight_duration_hours = Column(DECIMAL(6, 2))
    notes = Column(String(500))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    aircraft = relationship("Aircraft", back_populates="flights")
