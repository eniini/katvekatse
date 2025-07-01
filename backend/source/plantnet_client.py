import httpx
import os

PLANTNET_API_URL = "https://my.plantnet.org/v2/identify/all"
PLANTNET_API_KEY = os.getenv("PLANTNET_API_KEY")

async def identify_plant(image_bytes):
	files = {
		'images': ('plant.jpg', image_bytes, 'image/jpeg')
	}
	params = {
		'api-key': PLANTNET_API_KEY
	}
	async with httpx.AsyncClient() as client:
		response = await client.post(PLANTNET_API_URL, files=files, params=params)
	return response.json()