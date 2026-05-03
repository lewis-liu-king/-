from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class ScrapOrRetirementRecord(Base):
    __tablename__ = "scrap_or_retirement_records"
    
    retirement_id = Column(Integer, primary_key=True, autoincrement=True)
    component_id = Column(Integer, ForeignKey("components.component_id"), nullable=False, unique=True)
    retirement_reason = Column(String(100), nullable=False)
    approval_operator_id = Column(Integer, ForeignKey("operators.operator_id"))
    retirement_time = Column(DateTime, nullable=False)
    notes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    component = relationship("Component", back_populates="retirement")
    approval_operator = relationship("Operator", back_populates="retirements")
