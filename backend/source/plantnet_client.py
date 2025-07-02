import httpx
import os

PLANTNET_API_URL = "https://my.plantnet.org/v2/identify/all"
PLANTNET_API_KEY = os.getenv("PLANTNET_API_KEY")

async def identify_plant(image_bytes):
	files = {
		'images': ('plant.jpg', image_bytes, 'image/jpeg')
	}
	data = {
		'organs': 'leaf',  # Specify the organ type if needed, e.g., 'leaf', 'flower', etc.
	}
	params = {
		'include-related-images': 'false',  # Include related images in the response
		'no-reject': 'false',
		'nb-results': '1',  # Number of results to return
		'lang': 'en',  # Language for the response
		'api-key': PLANTNET_API_KEY
	}
	headers = {
		'accept': 'application/json',
	}

	print(f"Sending request to PlantNet API with {len(image_bytes)} bytes of image data.")

	async with httpx.AsyncClient() as client:
		try:
			response = await client.post(
				PLANTNET_API_URL,
				params=params,
				files=files,
				data=data,
				headers=headers
			)

			print(f"PlantNet API response status code: {response.status_code}")
			print(f"PlantNet API response headers: {response.headers}")
			print(f"PlantNet API response content: {response.text[:500]}")

			response.raise_for_status()

			return response.json()

		except httpx.HTTPStatusError as e:
			print(f"HTTP error occurred: {e.response.status_code} - {e.response.text[:300]}")
			return ({"error": "HTTP error occurred",
			"status_code": e.response.status_code,
			"message": {e.response.text[:300]}})

		except Exception as e:
			print(f"Unexpected error: {e}")
			return {
				"error": "Unknown backend error",
				"message": str(e)
			}
