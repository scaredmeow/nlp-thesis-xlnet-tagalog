import os

from dotenv import load_dotenv


class TwitterAPI:
    def __init__(self, url_list: list, dir: str):
        self.url_list = url_list
        self.dir = dir
        load_dotenv()

    def scraper(self):
        API_KEY, API_KEY_SECRET, BEARER_TOKEN, ACCESS_TOKEN, ACCESS_TOKEN_SECRET = (
            os.getenv("API_KEY"),
            os.getenv("API_KEY_SECRET"),
            os.getenv("BEARER_TOKEN"),
            os.getenv("ACCESS_TOKEN"),
            os.getenv("ACCESS_TOKEN_SECRET"),
        )
        print(
            f"API_KEY: {API_KEY}, API_KEY_SECRET: {API_KEY_SECRET}, BEARER_TOKEN: {BEARER_TOKEN}, ACCESS_TOKEN:"
            + f" {ACCESS_TOKEN}, ACCESS_TOKEN_SECRET: {ACCESS_TOKEN_SECRET}"
        )
