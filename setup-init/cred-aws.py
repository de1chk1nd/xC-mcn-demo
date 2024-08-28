import requests
import os
import time
import yaml
import subprocess
import configparser
import pathlib
from os.path import expanduser
from yaml.loader import SafeLoader
from pathlib import Path

def screen_clear():
   # for mac and linux(here, os.name is 'posix')
   if os.name == 'posix':
      _ = os.system('clear')
   else:
      # for windows platfrom
      _ = os.system('cls')
   # print out some text

#base_dir = os.path.dirname(__file__)
base_dir = pathlib.Path(__file__).parent.resolve()
root_dir = os.path.dirname(base_dir)
config_file = "config.yaml"

# Auslesen den AWS Credential Files
config = configparser.RawConfigParser()
credentials_file = '/.aws/credentials'
home = expanduser("~")
credentials_file = home + credentials_file
config.read(credentials_file)
file = Path(home+'/.aws/credentials')

file = home+'/.aws/credentials'
if os.path.exists(file):
  print('file already exists')
else:
  print('creating "dummy" aws/credentials file')
  os.mkdir(home+'/.aws')
  with open(file, mode='a'):pass


os.chdir(base_dir)
screen_clear()
print("###################################")
print("# REPLACE AWS Credentials")
print("#")
time.sleep(3)

with open(config_file) as f:
    data = yaml.load(f, Loader=SafeLoader)

profile = str(data['aws']['auth_profile'])

if config.has_section(profile):
  print ("# .aws/credentials Seciton exists")
  config[profile]['aws_access_key_id'] = str(data['aws']['aws_access_key_id'])
  config[profile]['aws_secret_access_key'] = str(data['aws']['aws_secret_access_key'])
  if data['aws']['tmp_aws_cred']:
    print ("# STS Auth discoverd")
    config[profile]['aws_session_token'] = str(data['aws']['aws_session_token'])
  else:
    config.remove_option(profile,'aws_session_token')


else:
  print ("# .aws/credentials does NOT exists - creating...")
  config.add_section(profile)
  config.set(profile, 'aws_access_key_id', str(data['aws']['aws_access_key_id']))
  config.set(profile, 'aws_secret_access_key', str(data['aws']['aws_secret_access_key']))
  if data['aws']['tmp_aws_cred']:
    print ("# STS Auth discoverd")
    config.set(profile, 'aws_session_token', str(data['aws']['aws_session_token']))

with open(credentials_file, 'w') as configfile:
  config.write(configfile)