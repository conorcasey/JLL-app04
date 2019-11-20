#!/usr/bin/python
# -*- coding: utf-8 -*-
#Author Ahead LLC
import collections
import datetime
import logging
import sys, time
import os
import requests, json


logging.basicConfig(format='%(levelname)s:%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p',level=logging.INFO)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

class TFConfigMgr(object):
    def __init__(self):
        pass


    def show_workspace(self, tfe_server, org_name, wksp_name, tf_token):
        tfe_server = tfe_server
        wksp_name = wksp_name
        org_name = org_name 
        tf_token = tf_token

        headers = {'Authorization': 'Bearer ' + tf_token, 'Content-Type': 'application/vnd.api+json'}
        url = 'https://' + tfe_server + '/api/v2/organizations/' + org_name + '/workspaces/' + wksp_name

        try:
            r = requests.get(url, headers=headers)
        except Exception as e:
            logging.error('Could not retrieve workspaceId due to the following: {0} '.format(e))
        return r


    def create_config_version(self, tfe_server, workspace_id):
        pass
        headers = {'Authorization': 'Bearer ' + tf_token, 'Content-Type': 'application/vnd.api+json'}
        url = 'https://' + tfe_server + '/api/v2/workspaces/' + workspace_id + '/configuration-versions'

        with open("Scripts/config_version.json", "r") as read_file:
            data = json.load(read_file)
       
        try:
            r = requests.post(url, headers=headers, data=json.dumps(data))
        except Exception as e:
            logging.error('Could not create config version due to the following: {0} '.format(e))
        return r


    def upload_config(self, config_version_upload_url):
        pass
        files = {'file': ('upload.tar.gz', open('upload.tar.gz', 'rb'), 'application/octet-stream', {'Expires': '0'})}
        headers = {'Authorization': 'Bearer ' + tf_token, 'Content-Type': 'application/vnd.api+json'}
        url = config_version_upload_url

        try:
            r = requests.put(url, files=files)
        except Exception as e:
            logging.error('Could not upload configurations due to the following: {0}'.format(e))
        return r


    def show_config_status(self, config_version_id):
        pass
        headers = {'Authorization': 'Bearer ' + tf_token, 'Content-Type': 'application/vnd.api+json'}
        url = 'https://' + tfe_server + '/api/v2/configuration-versions/' + config_version_id

        try:
            r = requests.get(url, headers=headers)
        except Exception as e:
            logging.error('Error requesting configuration version response: {0}'.format(e))
        return r


    def find_latest_run(self, workspace_id, config_version_id):
        pass
        headers = {'Authorization': 'Bearer ' + tf_token, 'Content-Type': 'application/vnd.api+json'}
        url = str('https://' + tfe_server + '/api/v2/workspaces/' + workspace_id + '/runs')
        logger.info('\n \n The url we are looking for is {0}\n \n'.format(url))

        r_status = 'pending'
        run_result = object
        has_changes = True
        job_complete = False
        job_report = {'status':r_status,'changes':has_changes,'job_complete':job_complete}

        while r_status == 'pending' or r_status == 'planning' or r_status == 'planned' or r_status == 'applying' or r_status == 'policy_checking':
            if r_status == 'planned' and has_changes == False:
                break
            time.sleep(10)
            try:
                run_request = requests.get(url, headers=headers)
            except Exception as e:
                logging.error('Could not list workspace runs due to the following: {0} '.format(e))

            for entry in run_request.json()['data']:
                if entry['relationships']['configuration-version']['data']['id'] == config_version_id:
                    run_result = entry
                    r_status = run_result['attributes']['status']
                    has_changes = run_result['attributes']['has-changes']
                    job_complete = False
                    logging.info('Current TFE job status: {0}'.format(r_status))
                    job_report = {'status':r_status,'changes':has_changes,'job_complete':job_complete}

        job_complete = True
        job_report = {'status':r_status,'changes':has_changes,'job_complete':job_complete}
        print("\n")
        logging.info('TFE has completed the job with a status of {0} and a change status of {1}'.format(r_status,run_result['attributes']['has-changes']))

        return job_report

    def run_status(self, run_id, tf_token):
    
        headers = {'Authorization': 'Bearer ' + tf_token, 'Content-Type': 'application/vnd.api+json'}
        url = 'https://' + tfe_server + '/api/v2/runs/' + run_id
    
        try:
            r = requests.get(url, headers=headers, verify=False)
        except Exception as e:
            logging.error('Error running status check : {0} '.format(e))
        return r

        
if __name__ == '__main__':
    #Pull workspace and organization name from environment
    #org_name = os.environ['ORGNAME']
    #wksp_name = os.environ['WORKSPACE']
    #tf_token = os.environ['TFTOKEN']
    tfe_server = sys.argv[1]
    org_name = sys.argv[2]
    wksp_name = sys.argv[3]
    tf_token = sys.argv[4]

   
    tf_mgr = TFConfigMgr()
    #Find the workspace_ID given the workspace name
    response = tf_mgr.show_workspace(tfe_server, org_name, wksp_name, tf_token)
    workspace_id = response.json()['data']['id']

    #Make sure we don't have an empty workspace_id
    if workspace_id == "":
        logging.error('WorkspaceId is empty. Exiting with error')
        sys.exit(1)
    logging.info('The workspaceId is {0} '.format(workspace_id))

    #Create the config version in TFE
    cv_response = tf_mgr.create_config_version(tfe_server, workspace_id)
    config_version_id = cv_response.json()['data']['id']
    config_version_upload_url = cv_response.json()['data']['attributes']['upload-url']

    #Make sure we don't have an empty config version
    if config_version_id == "":
        logging.error('Config versionID is empty. Exiting with error')
        sys.exit(1)
    logging.info('The ConfigVersionId is {0}'.format(config_version_id))

    #Make sure we don't have an empty upload URL
    if config_version_upload_url == "":
        logging.error('Config version upload URL is empty. Exiting with error')
        sys.exit(1)
    logging.info('The ConfigVersion Upload URL is {0} '.format(config_version_upload_url))

    #Upload the actual configuration and start a TFE run
    upload_response = tf_mgr.upload_config(config_version_upload_url)
    #print(type(upload_response))
    #<<-- Add some checking for this 200 response to make sure the reuest goes through
    logger.info(upload_response)
    
    #Validate the state of a run
    latest_run = tf_mgr.find_latest_run(workspace_id, config_version_id)

    ## Check configusation version job status
    get_response = tf_mgr.show_config_status(config_version_id)
    run_status = get_response.json()['data']['attributes']['status']
    logger.info('upload job configuration version status : %s' % run_status)
    
    timeout_counter = 0
    run_status = 'blank'
    while timeout_counter < 100 or run_status != 'uploaded':
        run_status = get_response.json()['data']['attributes']['status']
        logger.info('upload job configuration version status : %s' % run_status)
    
        if run_status == 'uploaded':
            logging.info('Job completed successfully')
            break
        elif run_status == 'errored':
            logging.error('Build exiting with error')
            sys.exit(1)
        else:
          timeout_counter += 1
          time.sleep(10)
    


    #<<-- Check to confirm the job in TFE completes successfully
    timeout_counter = 0
    job_status = ''
    while job_status != 'applied' or job_status != 'errored' or timeout_counter < 120:
        response = tf_mgr.run_status(run_id, tf_token)
        job_status = response.json()['data']['attributes']['status']
        print('Job status : %s' % job_status)
    
        if job_status == 'applied':
            logging.error('Job completed successfully')
            break
        elif job_status == 'errored':
            logging.error('Build exiting with error')
            sys.exit(1)
        else:
          timeout_counter += 1
          time.sleep(10)
    