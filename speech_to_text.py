import requests
import json
from Recorder import record_audio, read_audio
import os
import subprocess, signal
import re

# Wit speech API endpoint
API_ENDPOINT = 'https://api.wit.ai/speech'

# Wit.ai api access token
wit_access_token = 'OCHTBA4PODMZGN525OTWY4AJWVCBPITS'

def kill_mplayer():
    p = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
    out, err = p.communicate()
    for line in out.splitlines():
       if 'mplayer' in line:
         pid = int(line.split(None, 1)[0])
         os.kill(pid, signal.SIGKILL)

def RecognizeSpeech(AUDIO_FILENAME, num_seconds = 5):

    # record audio of specified length in specified audio file
    record_audio(num_seconds, AUDIO_FILENAME)

    # reading audio
    audio = read_audio(AUDIO_FILENAME)

    # defining headers for HTTP request
    headers = {'authorization': 'Bearer ' + wit_access_token,
               'Content-Type': 'audio/wav'}

    # making an HTTP post request
    resp = requests.post(API_ENDPOINT, headers = headers,
                         data = audio)

    # converting response content to JSON format
    data = json.loads(resp.content)
    # get text from data
    try:
        text = data['_text']
        print("\nYou said: {}".format(text))
    except:
        text = ""
        print("\nYou said: {}".format(text))

    text = re.sub("srf 1","srf1",text.lower())
    text = re.sub("sf1","srf1",text.lower())
    text = re.sub("sr1","srf1",text.lower())
    text = re.sub("srf 3","srf3",text.lower())
    text = re.sub("sf3","srf3",text.lower())
    text = re.sub("sr3","srf3",text.lower())
    text = re.sub("ruhe","ruhr",text.lower())
    text = re.sub("heimpsiel","heidi spiel",text)
    text = re.sub("hayden spiel","heidi spiel",text)
    text = re.sub("highspeed","heidi spiel",text)
    text = re.sub("handyspiel","heidi spiel",text)

    #understand what i need
    resp = requests.get('https://api.wit.ai/message?v=01.03.2018&q=(%s)' % text, headers = headers)

    data = json.loads(resp.content)
    print(resp.content)

    try:
        sender = data["entities"]['spiel'][0]["value"]
        print("\nI got entity : {}".format(sender))
    except:
        if text != "":
            os.system("mplayer nocomprendo1.wav")
        sender = ""
    if sender == "srf1" :
        kill_mplayer()
        os.system("mplayer http://stream.srg-ssr.ch/m/drs1/aacp_96  </dev/null >/dev/null 2>&1 &")
    if sender == "srf3":
        kill_mplayer()
        os.system("mplayer http://stream.srg-ssr.ch/m/drs3/aacp_96  </dev/null >/dev/null 2>&1 &")
    if sender == "espresso":
        kill_mplayer()
        os.system("mplayer $(youtube-dl -g http://tp.srgssr.ch/p/srf/inline\?urn\=urn:srf:audio:b88af97b-8d44-4b29-9b81-28e3e9be8657)")
    if sender == "ruhe":
        kill_mplayer()
        os.system("mplayer ja1.wav")

if __name__ == "__main__":
    while True:
        text =  RecognizeSpeech('myspeech.wav', 4)
