#!/usr/bin/python3.8

import json
from sys import stderr
import requests
from gevent.pywsgi import WSGIServer

from flask import Flask, request, Response, render_template
app = Flask(__name__)

import confuse
config = confuse.Configuration(__name__)
config.set_file('config.yaml')
config_data = config.get()

@app.route('/<path:chat_name>', methods=['POST'])
def post(chat_name=None):
    if chat_name not in config_data:
        return Response("Not found", status=404)
    dryRun = True if request.args.get('dry-run') else False

    try:
        data = json.loads(request.data)
    except Exception as e:
        print( str(e), file=stderr)
        return Response("Bad data format", status=400)

    template_name = config_data[chat_name]['template'] if 'template' in config_data[chat_name] else 'default'
    try:
        template = render_template('{}.tpl'.format( template_name ), data=data )
    except Exception as e:
        error = "Template {}.tpl error: {}".format( template_name, e )
        print( error, file=stderr)
        return Response( error, status=400)

    if dryRun:
        return Response(template, status=200)
    else:
        return send_message( config_data[chat_name], template )

def send_message(chat, alert):
    url = "https://api.telegram.org/bot{}/sendMessage".format( chat['token'] )

    if len(alert) > 4096:
        alert = alert[:4093] + '...'

    params = (
        ( "chat_id", chat['chat_id'] ),
        ( "text", alert ),
        ( "parse_mode", "markdown" ),
        ( "disable_web_page_preview", "True" ),
    )

    try:
      r = requests.post( url, params=params )
      r.raise_for_status()
    except requests.exceptions.HTTPError as e:
      print(e.response.text, file=stderr)
      print(alert, file=stderr)
      return Response(e.response.text, status=400)
    else:
      return Response('OK', status=200)

if __name__ == '__main__':
    http_server = WSGIServer(('', 5000), app)
    http_server.serve_forever()


