#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import json
import argparse
import pprint
import urllib3
import os
import random
import sys
import traceback
import csv

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
    
    # EXPORT HTML
    #pathexportfile = "/var/www/html/inventory/infra_inventory.html"
    #sys.stdout = open('/var/www/html/inventory/infra_inventory.html','w')

    testRestApi = TestRestApi()   
    status, cluster = testRestApi.getClusterInformation()
    print ("=" * 79)
    print "Name: %s" % cluster.get('name')
    print "ID: %s" % cluster.get('id')
    print "Cluster Nodes: %s" % cluster.get('num_nodes')

    for item in cluster.get('rackable_units'):
      print ("Service Tag : " + item['serial'] + " ,Model Name : " + item['model_name'] )

    #print "ServiceTag: %s" % cluster.get(['block_serials'][0])
    
    print "Version: %s" % cluster.get('version')
    print "Architecture: %s" % cluster.get('cluster_arch')
    print "Hypervisor Types: %s" % cluster.get(str('hypervisor_types'))
    print ("=" * 79)

    status, vmcluster = testRestApi.getVmInformation()

    print "Number of VMs on cluster: %s" % vmcluster.get('metadata'[2])
    
    print "List of VMs Names on cluster: "
    for item in sorted(vmcluster.get('entities')):
      
      # Voir le type item
      #print (item['num_vcpus'])
      #sorted()
      print ("Name : " + item['name'] + " ,Power State : " + item['power_state'] + " ,VCPUS Number : " + str(item['num_vcpus']) +
            " ,Cores Number : " + str(item['num_cores_per_vcpu']) + " ,Memory : " + str(item['memory_mb']/1024) + " Gb ")
    
    print ("=" * 79)
    print "Status code: %s" % status
    print "Text: "
    #pp.pprint(cluster)
    print ("=" * 79)

  except Exception as ex:
    print ex
    sys.exit(1)

