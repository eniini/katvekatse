from fastapi import FastAPI, File, UploadFile, Depends, Request
from plantnet_client import identify_plant
from database import Base, engine, SessionLocal
from sqlalchemy.orm import Session

import models, schemas

app = FastAPI()

Base.metadata.create_all(bind=engine)

def get_db():
	db = SessionLocal()
	try:
		yield db
	finally:
		db.close()

@app.post("/log")
async def log_api_result(
	log: schemas.ApiLogCreate,
	request: Request,
	db: Session = Depends(get_db)):
	db_log = models.ApiLog(
		client_ip=request.client.host,
		**log.model_dump()
	)
	db.add(db_log)
	db.commit()
	return {"status": "ok"}

@app.post("/identify")
async def identify(file: UploadFile = File(...)):
	image_bytes = await file.read()
	result = await identify_plant(image_bytes)
	return result
