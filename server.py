import asyncio
import websockets
import cv2
import numpy as np
import base64
import socket
import pyautogui
import qrcode 

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

def generate_qr_code(data):
    qr = qrcode.make(data)
    qr.show()  # Affiche le QR code dans une fenêtre
    print(f"QR Code généré: {data}")  # Affiche les informations du QR code dans la console

async def stream_screen(websocket, path):
    try:
        while True:
            # Capture d'écran avec pyautogui
            screenshot = pyautogui.screenshot()

            # Conversion de l'image PIL en array numpy
            frame = np.array(screenshot)

            # Conversion de RGB (pyautogui) à BGR (OpenCV)
            frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)

            # Encodage de l'image en JPEG
            _, buffer = cv2.imencode('.jpg', frame)

            # Conversion en base64
            jpg_as_text = base64.b64encode(buffer).decode()

            # Envoi de l'image encodée via WebSocket
            await websocket.send(jpg_as_text)

            # Petit délai pour contrôler le FPS
            await asyncio.sleep(0.1)  # Ajustez cette valeur pour modifier le FPS
    except websockets.exceptions.ConnectionClosed:
        pass

ip = get_ip()
port = 8765
connection_string = f"{ip}:{port}"  # Chaîne de connexion pour le QR code

print(f"Adresse IP du serveur: {ip}")
print(f"Port du serveur: {port}")
print(f"L'application mobile doit se connecter à: ws://{connection_string}")

# Générer et afficher le QR code
generate_qr_code(connection_string)

start_server = websockets.serve(stream_screen, ip, port)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
