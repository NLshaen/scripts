#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import json
#import argparse
import pprint
import urllib3
import os
import random
import sys
import traceback

#Vars

#URL de mon API REST NUTANIX
#url = "https://172.30.172.179:9440/PrismGateway/services/rest/v2.0/"

#Class test API REST TEST
class TestRestApi():                
  def __init__(self):
    
    self.serverIpAddress = "172.30.172.179"
    self.username = "ylu@nutanix.indus"
    self.password = "Jetemerde666!"
    BASE_URL = 'https://%s:9440/PrismGateway/services/rest/v2.0/'
    self.base_url = BASE_URL % self.serverIpAddress
    self.session = self.get_server_session(self.username, self.password)

#Define fonction server session
  def get_server_session(self, username, password):
 
    session = requests.Session()
    session.auth = (username, password)
    session.verify = False                                            
    session.headers.update(
        {'Content-Type': 'application/json; charset=utf-8'})
    return session

#Define fontion Cluster info
  def getClusterInformation(self):
   
    clusterURL = self.base_url + "/cluster"
    print "Getting cluster information for cluster %s" % self.serverIpAddress
    serverResponse = self.session.get(clusterURL)
    return serverResponse.status_code, json.loads(serverResponse.text)

#Define fonction Vm info
  def getVmInformation(self):

    vmURL = self.base_url + "/vms"
    print "Getting Vm information for cluster %s" % self.serverIpAddress
    serverResponse = self.session.get(vmURL)
    return serverResponse.status_code, json.loads(serverResponse.text)

#Execution command
if __name__ == "__main__":
  try:
    
    testRestApi = TestRestApi()   
    status, cluster = testRestApi.getClusterInformation()
    print ("=" * 79)
    print "Name: %s" % cluster.get('name')
    print "ID: %s" % cluster.get('id')
    print "Cluster Nodes: %s" % cluster.get('num_nodes')
    print "ServiceTag: %s" % cluster.get(['block_serials'][0])
    print "Version: %s" % cluster.get('version')
    print "Architecture: %s" % cluster.get('cluster_arch')
    print "Hypervisor Types: %s" % cluster.get('hypervisor_types')
    print ("=" * 79)
    status, vmcluster = testRestApi.getVmInformation()
    print "Number of VMs on cluster: %s" % vmcluster.get('metadata','count')
    print "List of VMs Names on cluster: "
    
    #status, vmcluster = testRestApi.getVmInformation()
    for item in vmcluster.get('entities'):
      print (item['name'])
    
    print ("=" * 79)
    print "Status code: %s" % status
    print "Text: "
    #pp.pprint(cluster)
    print ("=" * 79)

  except Exception as ex:
    print ex
    sys.exit(1)

