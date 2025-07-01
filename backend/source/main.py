from fastapi import FastAPI, File, UploadFile
import httpx
from plantnet_client import identify_plant

app = FastAPI()

@app.post("/identify")
async def identify(file: UploadFile = File(...)):
	image_bytes = await file.read()
	result = await identify_plant(image_bytes)
	return result