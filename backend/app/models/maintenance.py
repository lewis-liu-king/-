from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class MaintenanceRecord(Base):
    __tablename__ = "maintenance_records"
    
    maintenance_id = Column(Integer, primary_key=True, autoincrement=True)
    component_id = Column(Integer, ForeignKey("components.component_id"), nullable=False)
    work_order_number = Column(String(50), nullable=False, unique=True)
    maintenance_type = Column(String(50), nullable=False)
    description = Column(Text)
    operator_id = Column(Integer, ForeignKey("operators.operator_id"))
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime)
    result = Column(String(20))
    notes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    component = relationship("Component", back_populates="maintenances")
    operator = relationship("Operator", back_populates="maintenances")
