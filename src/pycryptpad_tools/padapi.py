from eliot import log_call
import os
import time
from selenium import webdriver
from selenium.webdriver.support.expected_conditions import url_contains, \
    presence_of_element_located, text_to_be_present_in_element
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait


class PadAPI:

    def __init__(self, base_url, headless=True):
        self.base_url = base_url
        self.headless = headless

    def __enter__(self):
        self.start_chrome_driver()
        return self

    def __exit__(self, type, value, traceback):
        # Give it some more time to save stuff.
        # Commands should wait until the content is saved, but just in case...
        time.sleep(1)
        self.quit()

    def start_chrome_driver(self):
        options = webdriver.ChromeOptions()
        options.add_argument('-lang=en')

        if self.headless:
            options.add_argument('headless')

        self.driver = webdriver.Chrome(options=options)

    def start_firefox_driver(self):
        if self.headless:
            os.environ['MOZ_HEADLESS'] = '1'

        self.driver = webdriver.Firefox()

    def quit(self):
        self.driver.quit()

    def _switch_to_sbox_iframe(self):
        self.driver.switch_to.default_content()
        self.driver.switch_to.frame("sbox-iframe")

    @log_call
    def create_pad(self):
        new_code_pad_url = f"{self.base_url}/code"
        self.driver.get(new_code_pad_url)
        WebDriverWait(self.driver, timeout=60).until(url_contains('#'))
        self._switch_to_sbox_iframe()
        WebDriverWait(self.driver, timeout=60).until(
            text_to_be_present_in_element((By.CLASS_NAME, 'cp-toolbar-spinner'), "Saved"))
        pad_url = self.driver.current_url
        pad_key = pad_url.split('/')[-2]
        return {
            "url": pad_url,
            "key": pad_key,
        }

    @log_call
    def codemirror_command(self, command):
        return self.driver.execute_script(f'''
            var editor = document.querySelector(".CodeMirror").CodeMirror;
            {command}
        ''')

    @log_call
    def open_pad(self, key):
        pad_url = f"{self.base_url}/code/#/2/code/edit/{key}/"
        self.driver.get(pad_url)
        self._switch_to_sbox_iframe()
        WebDriverWait(self.driver, timeout=60).until(
            presence_of_element_located((By.CLASS_NAME, 'cp-loading-hidden')))

    @log_call
    def set_pad_content(self, content):
        content = content.replace("\n", "\\n").replace('"', r'\"')
        self._switch_to_sbox_iframe()
        self.codemirror_command(f'editor.setValue("{content}");')
        WebDriverWait(self.driver, timeout=60).until(
            text_to_be_present_in_element((By.CLASS_NAME, 'cp-toolbar-spinner'), "Saved"))

    @log_call
    def get_pad_content(self):
        return self.codemirror_command("return editor.getValue();")
