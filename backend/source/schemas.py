from pydantic import BaseModel, Field
from typing import Optional, List
from uuid import UUID
from datetime import datetime

class UserDiaryCreate(BaseModel):
	user_id: UUID
	plant_name: str
	confidence: float

class ApiLogCreate(BaseModel):
	client_ip: Optional[str]
	user_uuid: Optional[UUID]
	plant_id: Optional[str]
	confidence: Optional[float]
	organs: Optional[List[str]]
	request_status_code: Optional[int]
	plantnet_response_time_ms: Optional[int]
	plantnet_raw_response: Optional[dict]
	