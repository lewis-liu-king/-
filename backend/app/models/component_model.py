from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class ComponentModel(Base):
    __tablename__ = "component_models"
    
    model_id = Column(Integer, primary_key=True, autoincrement=True)
    model_code = Column(String(50), nullable=False, unique=True)
    category = Column(String(50), nullable=False)
    design_life_hours = Column(Integer)
    maintenance_interval_hours = Column(Integer)
    applicable_aircraft_models = Column(Text)
    description = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    components = relationship("Component", back_populates="model")
