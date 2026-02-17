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
#url = 'http://ifconfig.me/ip'
url = 'http://api.ipify.org'
response = requests.get(url)

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
print("# preparing Config file")
print("# parsing YAML config file and")
print("# auto-polulating with your current (public)-IP: "+str(response.text))
print("#")
time.sleep(3)

with open(config_file) as f:
    data = yaml.load(f, Loader=SafeLoader)

data['student']['ip-address'] = response.text+"/32"

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


# Write to files

with open(config_file, 'w') as f:
    yaml.dump(data, f, default_flow_style=False)

with open(credentials_file, 'w') as configfile:
  config.write(configfile)

print("#")
print("# Set xC Cert File environment Variable")
os.environ["VES_P12_PASSWORD"] = data['xC']['p_12_pwd']

time.sleep(3)
print("#")
print("# Deploy Terraform")
print("#")

os.chdir(root_dir)

p12_password = data['xC']['p_12_pwd']
p12_file = os.path.normpath(os.path.join(base_dir, data['xC']['p12_auth']))
os.system(f"openssl pkcs12 -in '{p12_file}' -out './setup-init/.xC/xc-curl.crt.pem' -passin 'pass:{p12_password}' -passout 'pass:{p12_password}' -legacy")

os.system('terraform -chdir="./infrastructure" fmt')
os.system('terraform -chdir="./infrastructure" init')
os.system('terraform -chdir="./infrastructure" plan')
os.system('terraform -chdir="./infrastructure" apply -auto-approve')