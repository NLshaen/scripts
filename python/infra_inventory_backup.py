#!/usr/bin/env python
# -*- coding: utf-8 -*-

#python 2.7.5
#yan.lucas@external.thalesaleniaspace.com

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

from collections import OrderedDict
from operator import itemgetter, attrgetter, methodcaller

#import locale
#locale.setlocale(locale.LC_ALL, 'utf-8')

#Vars

#URL API REST NUTANIX
#url = "https://172.30.172.179:9440/PrismGateway/services/rest/v2.0/"

#echo 'import crypt,getpass; print crypt.crypt(getpass.getpass(), "$6$TASSalt")' | python -
#$6$TASSalt$5Q3WshgOijNAohsW3va.Q/jfv/kbfziP0xVL3jNaOxNNDhQ7R/JRZjawLEM0xvQzWVDuAga6fvaPN3EKbOu1y/

#Class test API REST TEST
class TestRestApi():                
  def __init__(self):
    """Init the connection to the REST API Explore"""
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    self.serverIpAddress = "172.30.172.179"
    self.username = "ylu@nutanix.indus"
    #self.password = "$6$TASSalt$5Q3WshgOijNAohsW3va.Q/jfv/kbfziP0xVL3jNaOxNNDhQ7R/JRZjawLEM0xvQzWVDuAga6fvaPN3EKbOu1y/"
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

#Define fonction Cluster info
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

#Define sort dictionnary
  def tri(dico):
    items = dico.items()
    comparateur = lambda a,b : cmp(a[1],b[1])
    return sorted(items, comparateur, reserve=True)

#Define fonction print to hmtl
  def printToHTML(self, myCustomList, htmlfile):    
      # DEBUG LIST
      print "===== DEBUG ("+ str(len(myCustomList)) +") ====="
      print str(myCustomList)

      html =  "<html>\n<head><title>INVENTORY NUTANIX</title>\n<style>p { margin: 0 !important; } table { border: 1px solid #000; width: 500px; }</style></head>\n<body>\n"

      html += '\n<p>This page was last updated on ' + "XXX" + '</p>\n'

      for item in myCustomList:
        # DEBUG LIST
        #print "===== DEBUG ITEM ====="
        #print str(item['memory'])
        
        html += '<table><tr colspan=\"2\"><th>VM Name</th></tr>'
        
        orderedItem = list()
        orderedItem.append('name')
        orderedItem.extend( sorted( (key for key in item.keys() if key not in orderedItem), key=lambda f: f[0]) )
        
        for key in orderedItem:
          html += '<tr><td>'+ key +'</td><td>' + str(item[key]) + '</td></tr>\n'
          
        html += '</table>'

      # Finish HTML
      html += "\n</body></html>"

      with open(htmlfile, 'w') as f:
        f.write(html)
        f.close()


#Execution command
if __name__ == "__main__":
  try:
    
    # EXPORT HTML
    #outputfile = open('/var/www/html/inventory/output/infra_inventory.html','w')
    #sys.stdout = open('/var/www/html/inventory/output/infra_inventory.html','w')

    testRestApi = TestRestApi()   
    
    status, cluster = testRestApi.getClusterInformation()
    
    print ("=" * 100)
    print "Name: %s" % cluster.get('name')
    print "ID: %s" % cluster.get('id')
    print "Cluster Nodes: %s" % cluster.get('num_nodes')
    
    for item in cluster.get('rackable_units'):
      print ("Service Tag : " + item['serial'] + " ,Model Name : " + item['model_name'] )

      print "Version: %s" % cluster.get('version')
      print "Architecture: %s" % cluster.get('cluster_arch')
      hypervtype = cluster.get('hypervisor_types')
      print "Hypervisor Types: %s" % hypervtype[0]
    print ("=" * 100)

    status, vm = testRestApi.getVmInformation()
    
    numbervm = vm.get('metadata')
    print (numbervm.values())
    print ("Number of VMs on cluster: %s"  % numbervm[u'count'])
    print "List of VMs Names on cluster: "
    
    myCustomList = list()
    for item in vm.get('entities'):
      vmname = item['name']
      vmpwstate = item['power_state']
      vmcpunumber = item['num_vcpus']
      vmcore = item['num_cores_per_vcpu']
      vmmemory = item['memory_mb']/1024
      
      myCustomDictionnary = {
        "name": vmname,
        "state": vmpwstate,
        "vcpu": vmcpunumber,
        "core": vmcore,
        "memory": vmmemory
      }
      myCustomList.append(myCustomDictionnary)
    
    # Sort by memory value (cast as integer)
    #myCustomList.sort(key=lambda f: int(f['memory']))
    #print "====== SORT BY MEMORY ======"
    #print( str(myCustomList) )
    
    # Sort by name value
    myCustomList.sort(key=lambda f: f['name'])
    print "====== SORT BY NAME ======"
    print( str(myCustomList) )
    testRestApi.printToHTML(myCustomList, '/var/www/html/inventory/output/infra_inventory.html' )
    

    print ("*" * 100)
    print "Status code: %s" % status
    print ("*" * 100)
    #print >> outputfile, item

  except Exception as ex:
    print ex
    sys.exit(1)

