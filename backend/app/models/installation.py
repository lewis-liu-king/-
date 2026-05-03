from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class InstallationRecord(Base):
    __tablename__ = "installation_records"
    
    installation_id = Column(Integer, primary_key=True, autoincrement=True)
    component_id = Column(Integer, ForeignKey("components.component_id"), nullable=False)
    aircraft_id = Column(Integer, ForeignKey("aircrafts.aircraft_id"), nullable=False)
    installation_position = Column(String(100), nullable=False)
    installation_reason = Column(Text)
    installation_operator_id = Column(Integer, ForeignKey("operators.operator_id"))
    installation_time = Column(DateTime, nullable=False)
    removal_reason = Column(Text)
    removal_operator_id = Column(Integer, ForeignKey("operators.operator_id"))
    removal_time = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    component = relationship("Component", back_populates="installations")
    aircraft = relationship("Aircraft", back_populates="installations")
    installation_operator = relationship(
        "Operator",
        foreign_keys=[installation_operator_id],
        back_populates="installations_as_installer"
    )
    removal_operator = relationship(
        "Operator",
        foreign_keys=[removal_operator_id],
        back_populates="installations_as_remover"
    )
