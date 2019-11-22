#!/usr/bin/python
# -*- coding: utf-8 -*-
#Author Ahead LLC
import collections
import datetime
import logging
import sys, time
import os
import requests, json
import xml.etree.ElementTree as ET

logging.basicConfig(format='%(levelname)s:%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p',level=logging.INFO)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

class panosConfigMgr(object):
    def __init__(self):
        pass

    # Generate access token
    def panos_get_apikey(self, firewall, username, password):
        url = 'https://' + firewall + '/api/?type=keygen&user=' + username + '&password=' + password

        try:
            r = requests.get(url, verify=False)
        except Exception as e:
            logging.error('Tooken request was not successful : {0}'.format(e))
        return r


    # Commit firewall updates
    def panos_commit(self, apikey):
        url = 'https://' + firewall + '/api/?type=commit&cmd=<commit></commit>&key=' + apikey

        try:
            r = requests.put(url, verify=False)
        except Exception as e:
            logging.error('Commit was not successfull : {0} '.format(e))
        return r

    # Commit firewall updates
    def panos_commit_status(self, job_id, apikey):
        url = 'https://' + firewall + '/api/?type=op&cmd=<show><jobs><id>' + job_id + '</id></jobs></show>&key=' + apikey
    
        try:
            r = requests.put(url, verify=False)
        except Exception as e:
            logging.error('Could not find job Id : {0} '.format(e))
        return r


if __name__ == '__main__':

    firewall = sys.argv[1]
    username = sys.argv[2]
    password = sys.argv[3]

    panos_mgr = panosConfigMgr()

    # Request Palo Alto API Key
    response = panos_mgr.panos_get_apikey(firewall, username, password)

    # Parse the XML response for the API Key.
    root = ET.fromstring(response.content)
    print(response.content)
    #apikey = root[0][0].text
    apikey = root.find('result')[0].text
    logger.info('API Key : ' + apikey)

    # Make API request to PaloAlto firewall to execute a commit.
    logger.info('Commit firewall updates if necessary')
    response = panos_mgr.panos_commit(apikey)
    logger.debug(response.content)
    root = ET.fromstring(response.content)

    # Check for a 'result' element was returned. If not it means no firewall commit was necessary 
    if root.find('result') is None:
        logger.info('No firewall updates to commit')
    else:
        #commit_job_id = root[0][1].text
        commit_job_id = root.find('result').find('job').text
        logger.info('Commit Job Id : ' + commit_job_id)
  
        # Monitor status of commit
        response = panos_mgr.panos_commit_status(commit_job_id, apikey)
        root = ET.fromstring(response.content)
        #commit_job_status = root[0][0][5].text
        commit_job_status = root.find('result').find('job').find('status').text
        logger.info('Commit Job Status : ' + commit_job_status)

        while commit_job_status != "FIN":
            time.sleep(5)
            response = panos_mgr.panos_commit_status(commit_job_id, apikey)
            root = ET.fromstring(response.content)
            #commit_job_status = root[0][0][5].text
            commit_job_status = root.find('result').find('job').find('status').text
            logger.info('Commit Job Status : ' + commit_job_status)
        else:
            logger.info("Commit complete")
