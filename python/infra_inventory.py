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
import datetime

from collections import OrderedDict
from operator import itemgetter, attrgetter, methodcaller

#import locale
#locale.setlocale(locale.LC_ALL, 'utf-8')

#VARS

#URL API REST NUTANIX
#url = "https://172.30.172.179:9440/PrismGateway/services/rest/v2.0/"

#echo 'import crypt,getpass; print crypt.crypt(getpass.getpass(), "$6$TASSalt")' | python -
#$6$TASSalt$5Q3WshgOijNAohsW3va.Q/jfv/kbfziP0xVL3jNaOxNNDhQ7R/JRZjawLEM0xvQzWVDuAga6fvaPN3EKbOu1y/

#Class Nutanix API REST
class NutanixApiRest():                
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
  def printToHTML(self, myClusterList, myVmList, htmlfile):    
      # DEBUG LIST
      print "===== DEBUG ("+ str(len(myClusterList)) +") ====="
      print ( str(myClusterList), str(myVmList) )

      datetime_object=datetime.datetime.now()      

      html =  "<html>\n<head><title>INVENTORY NUTANIX</title>\n<style>p { margin: 0 !important; } table { border: 1px solid #000; width: 900px; }</style></head>\n<body>\n"

      html += '\n<p>This page was last updated on ' + str(datetime_object) + '</p>\n'

      for item in myClusterList:
        html += '<table><tr colspan=\"2\"><th>Cluster Name</th></tr>'
        
        orderedItem = list()
        orderedItem.append('clustername')
        orderedItem.extend( sorted( (key for key in item.keys() if key not in orderedItem), key=lambda f: f[0]) )

        for key in orderedItem:
          html += '<td>'+ key +':' + str(item[key]) + '</td>'
        html += '</table>'

      for item in myVmList:
        # DEBUG LIST
        #print "===== DEBUG ITEM ====="
        #print str(item['vmname'])
        
        html += '<table><tr colspan=\"2\"><th>VM Name</th></tr>'
        
        orderedItem = list()
        orderedItem.append('vmname')
        orderedItem.extend( sorted( (key for key in item.keys() if key not in orderedItem), key=lambda f: f[0]) )
        
        for key in orderedItem:
          html += '<td>'+ key +':' + str(item[key]) + '</td>'
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

    Nutanix = NutanixApiRest()   
    
    status, cluster = Nutanix.getClusterInformation()
    
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

    status, vm = Nutanix.getVmInformation()
    
    numbervm = vm.get('metadata')
    print (numbervm.values())
    print ("Number of VMs on cluster: %s"  % numbervm[u'count'])
    print "List of VMs Names on cluster: "
    
    myClusterList = list()
    
    clustername = cluster.get('name')
    clusterid = cluster.get('id')
    clusternodes = cluster.get('num_nodes')

    for item in cluster.get('rackable_units'):
      clusterservicetag = item['serial']
      clustermodelname = item['model_name']
      clusterversion = cluster.get('version')
      clusterarch = cluster.get('cluster_arch')
      clusterhypervtype = cluster.get('hypervisor_types')

      myClusterDictionnary = {
        "clustername": clustername,
        "clusterid": clusterid,
        "clusternodes": clusternodes,
        "clusterservicetag": clusterservicetag,
        "clustermodelname": clustermodelname,
        "clusterversion": clusterversion,
        "clusterarch": clusterarch,
        "clusterhypervtype": clusterhypervtype
      }
      myClusterList.append(myClusterDictionnary)

    # Sort by clustername value
    myClusterList.sort(key=lambda f: f['clustername'])
    print "====== SORT BY CLUSTER NAME ======"
    print( str(myClusterList) )

    #Nutanix.printToHTML(myClusterList, '/var/www/html/inventory/output/infra_inventory.html' )

    myVmList = list()

    vmnumber = vm.get('metadata')

    for item in vm.get('entities'):
      vmname = item['name']
      vmpwstate = item['power_state']
      vmcpunumber = item['num_vcpus']
      vmcore = item['num_cores_per_vcpu']
      vmmemory = item['memory_mb']/1024
      
      myVmDictionnary = {
        "vmnumber": vmnumber,
        "vmname": vmname,
        "vmstate": vmpwstate,
        "vmvcpu": vmcpunumber,
        "vmcore": vmcore,
        "vmmemory": vmmemory
      }
      myVmList.append(myVmDictionnary)
    
    # Sort by vmmemory value (cast as integer)
    #myVmList.sort(key=lambda f: int(f['vmmemory']))
    #print "====== SORT BY VM MEMORY ======"
    #print( str(myVmList) )
    
    # Sort by vmname value
    myVmList.sort(key=lambda f: f['vmname'])
    print "====== SORT BY VM NAME ======"
    print( str(myVmList) )
   
    Nutanix.printToHTML(myClusterList, myVmList, '/var/www/html/inventory/output/infra_inventory.html' )
    
    print ("*" * 100)
    print "Status code: %s" % status
    print ("*" * 100)

  except Exception as ex:
    print ex
    sys.exit(1)

