import threading
import json 
import requests
import urllib
import cv2
from io import BytesIO
import telegram
from PIL import Image
#from MotorControl import api as MC


class MessageBotThread (threading.Thread):

    def __init__(self, threadID, thread_name):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = thread_name
        self.TOKEN = "501932857:AAEvQCN3zfmeBTwWABZxjN_P-UojD5paC5Q"
        self.URL = None
        self.bot = None
        self.USER = None
        self.enable_images = False
        self.update()
        self.sensor = None
    

    def update(self):
        self.URL = "https://api.telegram.org/bot{}/".format(self.TOKEN)
        self.bot = telegram.Bot(self.TOKEN)

    def run(self):
        self.update()
        last_update_id = None
        while True:
            updates = self.get_updates(last_update_id)
            if len(updates["result"]) > 0:
                last_update_id = self.get_last_update_id(updates) + 1
                self.echo_all(updates)
                
    def get_url(self, url):
        response = requests.get(url)
        content = response.content.decode("utf8")
        return content
    
    
    def get_json_from_url(self, url):
        content = self.get_url(url)
        js = json.loads(content)
        return js
    
    
    def get_updates(self, offset=None):
        url = self.URL + "getUpdates?timeout=10"
        if offset:
            url += "&offset={}".format(offset)
        js = self.get_json_from_url(url)
        return js
    
    
    def get_last_chat_id_and_text(self, updates):
        num_updates = len(updates["result"])
        last_update = num_updates - 1
        text = updates["result"][last_update]["message"]["text"]
        chat_id = updates["result"][last_update]["message"]["chat"]["id"]
        return (text, chat_id)
    
    
    def send_message(self, text, chat_id):
        text = urllib.parse.quote_plus(text)
        url = self.URL + "sendMessage?text={}&chat_id={}".format(text, chat_id)
        self.get_url(url)
        
    def get_last_update_id(self, updates):
        update_ids = []
        for update in updates["result"]:
            update_ids.append(int(update["update_id"]))
        return max(update_ids)

    def send_image(self):
        cap = cv2.VideoCapture(1)
        (ret, frame) = cap.read()
        if not ret:
            cap.release()
            cap = cv2.VideoCapture(0)
            (ret, frame) = cap.read()
            
        image = Image.fromarray(frame)
        bio = BytesIO()
        bio.name = 'image.jpeg'
        image.save(bio, 'JPEG')
        bio.seek(0)
        self.bot.send_photo(self.USER, bio)
        cap.release()
    
    def echo_all(self, updates):
        for update in updates["result"]:
            try:
                if update["message"]["from"]["id"] == self.USER:
                    text = update["message"]["text"]
                    chat = update["message"]["chat"]["id"]
                    self.send_message(text, chat)
                    if text == 'image':
                        if self.enable_images:
                            self.send_image()
            
            except Exception as e:
                print(e)

    def end(self, e):
        e = 'Program has ended: ' + e
        self.bot.sendMessage(self.USER, e)
