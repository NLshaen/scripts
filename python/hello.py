#! /usr/bin/python

# -*- coding:utf-8 -*-


from flask import Flask
from flask import render_template

from infra_inventory import NutanixApiRest

app = Flask(__name__)

@app.route('/')

def index():

    var = "Flask html"
    return render_template('infra_inventory.html', name='INFRA NUTANIX INVENTORY', myCustomList=['test','another','again']) 

if __name__ == '__main__':
    
    Nutanix = NutanixApiRest()
 
    status, cluster = Nutanix.getClusterInformation()
    print ("=" * 100)
    print "Name: %s" % cluster.get('name')
    print "ID: %s" % cluster.get('id')
    print "Cluster Nodes: %s" % cluster.get('num_nodes')



    app.run(host='0.0.0.0', port='5000', debug=True)
