from sqlalchemy import Column, String, Float, Integer, JSON, TIMESTAMP, ARRAY
from sqlalchemy.dialects.postgresql import UUID, INET
import uuid
from .database import Base

class UserDiary(Base):
	__tablename__ = "user_diary"
	id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
	user_id = Column(UUID(as_uuid=True), nullable=False)
	plant_name = Column(String, nullable=False)
	confidence = Column(Float, nullable=False)
	created_at = Column(TIMESTAMP, server_default="now()")

class ApiLog(Base):
	__tablename__ = "api_log"
	id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
	timestamp = Column(TIMESTAMP, server_default="now()")
	client_ip = Column(INET)
	user_uuid = Column(UUID(as_uuid=True), nullable=True)
	plant_id = Column(String)
	confidence = Column(Float)
	organs = Column(ARRAY(String))
	request_status_code = Column(Integer)
	plantnet_response_time_ms = Column(Integer)
	plantnet_raw_response = Column(JSON)
