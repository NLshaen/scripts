#! /usr/bin/python

# -*- coding:utf-8 -*-


from flask import Flask
from flask import render_template

app = Flask(__name__)


@app.route('/')

def index():

    var = "Flask html"
    return render_template('infra_inventory.html', name='CAMERLO JOEY alias the snake',
    mylist=[0,1,3]) 

if __name__ == '__main__':

    app.run(host='0.0.0.0', port='5000', debug=True)
