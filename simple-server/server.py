import flask
import os

app = flask.Flask(__name__)
app.config["DEBUG"] = True

port = os.environ['PORT'] if 'PORT' in os.environ else 5000

@app.route('/', methods=['GET'])
def home():
    return "<h1>TEST</h1><p>42</p>"

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=port)