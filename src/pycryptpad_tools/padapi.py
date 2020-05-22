from functools import partial
import os
import time
from eliot import log_call, start_action
from selenium import webdriver
from selenium.webdriver.support.expected_conditions import url_contains, \
    presence_of_element_located, text_to_be_present_in_element
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait


log_call_no_result = partial(log_call, include_result=False)


class PadAPI:

    @log_call_no_result
    def __init__(self, base_url, headless=True):
        self.base_url = base_url.strip("/")
        self.headless = headless

    def __enter__(self):
        self.start_chrome_driver()
        return self

    def __exit__(self, type, value, traceback):
        # Give it some more time to save stuff.
        # Commands should wait until the content is saved, but just in case...
        time.sleep(1)
        self.quit()

    @log_call_no_result
    def start_chrome_driver(self):
        options = webdriver.ChromeOptions()
        options.add_argument('-lang=en')

        if self.headless:
            options.add_argument('headless')

        self.driver = webdriver.Chrome(options=options)

    @log_call_no_result
    def start_firefox_driver(self):
        if self.headless:
            os.environ['MOZ_HEADLESS'] = '1'

        self.driver = webdriver.Firefox()

    def quit(self):
        self.driver.quit()

    @log_call_no_result
    def _switch_to_sbox_iframe(self):
        self.driver.switch_to.default_content()
        self.driver.switch_to.frame("sbox-iframe")

    @log_call_no_result
    def create_pad(self, initial_content=""):
        new_code_pad_url = self.base_url + "/code/"
        with start_action(action_type="open_new_pad",
                          new_code_pad_url=new_code_pad_url):
            self.driver.get(new_code_pad_url)
            WebDriverWait(self.driver, timeout=60).until(url_contains('#'))


        self._switch_to_sbox_iframe()
        WebDriverWait(self.driver, timeout=60).until(
            text_to_be_present_in_element((By.CLASS_NAME, 'cp-toolbar-spinner'), "Saved"))
        pad_url = self.driver.current_url
        pad_key = pad_url.split('/')[-2]
        self.set_pad_content(initial_content)
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

    @log_call_no_result
    def open_pad(self, key):
        pad_url = f"{self.base_url}/code/#/2/code/edit/{key}/"
        self.driver.get(pad_url)
        self._switch_to_sbox_iframe()
        WebDriverWait(self.driver, timeout=60).until(
            presence_of_element_located((By.CLASS_NAME, 'cp-loading-hidden')))

    @log_call_no_result
    def set_pad_content(self, content):
        content = content.replace("\n", "\\n").replace('"', r'\"')
        self._switch_to_sbox_iframe()
        self.codemirror_command(f'editor.setValue("{content}");')
        WebDriverWait(self.driver, timeout=60).until(
            text_to_be_present_in_element((By.CLASS_NAME, 'cp-toolbar-spinner'), "Saved"))

    @log_call
    def get_pad_content(self):
        return self.codemirror_command("return editor.getValue();")
