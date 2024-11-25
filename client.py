import asyncio
import websockets
import cv2
import numpy as np
from PIL import ImageGrab


async def send_screen(websocket, path):
    while True:
        # Capture l'écran
        screen = ImageGrab.grab()
        screen_np = np.array(screen)
        screen_bgr = cv2.cvtColor(screen_np, cv2.COLOR_RGB2BGR)

        # Redimensionne l'image
        img_resized = cv2.resize(screen_bgr, (400, 1000))  # (largeur, hauteur)

        # Encode l'image en JPEG
        _, buffer = cv2.imencode('.jpg', img_resized)
        frame = buffer.tobytes()

        # Envoie l'image au client
        await websocket.send(frame)
        await asyncio.sleep(0.1)  # Envoie toutes les 100 ms


start_server = websockets.serve(send_screen, "localhost", 6789)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
