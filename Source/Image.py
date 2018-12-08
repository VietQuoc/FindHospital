import Selenium2Library
import os
from robot.libraries.BuiltIn import BuiltIn
import  urllib


def download_file(url, file_name):
        urllib.request.urlretrieve(url, file_name+".jpg")