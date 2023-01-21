---
title: Onboard a Google Cloud Platform project to Entra Permissions Management
description: Onboarding Google Cloud Platorm project to Microsoft Entra Permissions
  Management
date: 2023-01-20T22:46:04.354Z
preview: /img/entra/gcp.png
draft: false
tags:
  - Entra Permissions Management
  - Google Cloud Platform
categories:
  - Entra Permissions Management
lastmod: 2023-01-21T00:32:55.494Z
thumbnail: /img/entra/gcp.png
lead: ""
---

In a previous post I blogged about how to setup Microsoft Entra Permissions Management and onboarding an Microsoft Azure Subscription. In this post I will show how to onboard a Google Cloud Platform project.

First let's login to the Entra Permissions Management dashboard.

![Image](/img/entra/entra-gcp-01.jpg)

Click on the gear in the top right corner to open up the Data Collectors dashboard.

![Image](/img/entra/entra-gcp-02.jpg)

Click the GCP under the Data Collectors tab then click Create Configuration. In the Configure data collection: GCP window we will need information about our Google Cloud project. That information can be found on your Google Cloud Project info dashboard.

We will create the Azure AD OIDC App first. The script that will run looks like this:

```
#use this script for Azure version <3.7 
az ad app create --display-name "mciem-gcp-oidc-app" --identifier-uris "api://mciem-gcp-oidc-app" --available-to-other-tenants false 

#use this script for Azure version >3.7 
az ad app create --display-name "mciem-gcp-oidc-app" --identifier-uris "api://mciem-gcp-oidc-app" --sign-in-audience AzureADMyOrg 

#PowerShell Script 
New-AzureADApplication -DisplayName  "mciem-gcp-oidc-app" -IdentifierUris "api://mciem-gcp-oidc-app" 
```
Note: In order for the first line to run I had to remove the --available-to-other-tenants false.  I will look into this and update this blog.

Also, take note that you will need to only run the first or 2nd line depending on Azure version.  Then run the 3rd line in Azure Powershell.



![Image](/img/entra/entra-gcp-03.jpg)


![Image](/img/entra/entra-gcp-04.jpg)

Once the required fields have been filled in.  We will copy the script under Google Cloud Script.  This script looks like this:

```
#!/bin/bash -x

export AZURE_APP_ID=b46c3ac5-9da6-418f-a849-0a07a10b3c6c
export AZURE_TENANT_ID=bc1693b0-9755-40dc-98c0-ae29a51cc39d
export AZURE_AUTHORITY_URL=sts.windows.net

export GCP_OIDC_PROJECT_NUMBER=321301204886
export GCP_OIDC_SERVICE_ACCOUNT_NAME=mciem-service
export GCP_OIDC_WIP_ID=mciem-wi-pool
export GCP_OIDC_WIP_PROVIDER_ID=mciem-wi-provider

export GCP_OIDC_PROJECT_NAME=$(gcloud projects list --filter="PROJECT_NUMBER=$GCP_OIDC_PROJECT_NUMBER" --format="value(projectName)")
export GCP_OIDC_PROJECT_ID=$(gcloud projects list --filter="PROJECT_NUMBER=$GCP_OIDC_PROJECT_NUMBER" --format="value(projectId)")

gcloud config set project $GCP_OIDC_PROJECT_ID

echo In project name:$GCP_OIDC_PROJECT_NAME number:$GCP_OIDC_PROJECT_NUMBER id:$GCP_OIDC_PROJECT_ID

echo Enabling IAM API in project $GCP_OIDC_PROJECT_ID
gcloud services enable iam.googleapis.com

echo Enabling IAM Credential API in project $GCP_OIDC_PROJECT_ID
gcloud services enable iamcredentials.googleapis.com

echo Enabling IAM Credential API in project $GCP_OIDC_PROJECT_ID
gcloud services enable cloudresourcemanager.googleapis.com

echo Create workload identity pool ${GCP_OIDC_WIP_ID}
gcloud iam workload-identity-pools \
  create ${GCP_OIDC_WIP_ID} \
  --location="global" \
  --description="ms-ciem-workload-identity-pool" \
  --display-name="ms-ciem-workload-identity-pool"

echo Create workload identity pool provider ${GCP_OIDC_WIP_PROVIDER_ID}
gcloud iam workload-identity-pools providers \
  create-oidc ${GCP_OIDC_WIP_PROVIDER_ID} \
  --location=global \
  --description="ms-ciem-wip-provider" \
  --display-name="ms-ciem-wip-provider" \
  --workload-identity-pool="${GCP_OIDC_WIP_ID}" \
  --issuer-uri="https://${AZURE_AUTHORITY_URL}/${AZURE_TENANT_ID}/" \
  --allowed-audiences="api://mciem-gcp-oidc-app" \
  --attribute-condition="attribute.appid==\"${AZURE_APP_ID}\"" \
--attribute-mapping="google.subject=assertion.sub, attribute.tid=assertion.tid, attribute.appid=assertion.appid"


echo Create IAM service account ${GCP_OIDC_SERVICE_ACCOUNT_NAME}
gcloud iam service-accounts \
  create ${GCP_OIDC_SERVICE_ACCOUNT_NAME} \
  --description="ms-ciem-service-account" \
  --display-name="ms-ciem-service-account"

echo Add IAM policy binding for iam.workloadIdentityUser to ${GCP_OIDC_SERVICE_ACCOUNT_NAME}@${GCP_OIDC_PROJECT_ID}.iam.gserviceaccount.com
gcloud iam service-accounts \
  add-iam-policy-binding projects/${GCP_OIDC_PROJECT_ID}/serviceAccounts/${GCP_OIDC_SERVICE_ACCOUNT_NAME}@${GCP_OIDC_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "principalSet://iam.googleapis.com/projects/${GCP_OIDC_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${GCP_OIDC_WIP_ID}/*"
```
You can run this script from within Google Cloud's Shell just like we did for the Azure based scripts. Click to download the script.  Open up GCP Shell then upload the script.

![Image](/img/entra/entra-gcp-05.jpg)

Once we click next we will need to create the role bindings.  I am going to do this at the Organization level.  Download the script that is needed to run and upload it to Google CLI again.

![Image](/img/entra/entra-gcp-06.jpg)

Make sure you change the OrgID.

```
gcloud organizations add-iam-policy-binding <orgID> --member="serviceAccount:mciem-service@gcp-oidc-entra-demo.iam.gserviceaccount.com" --role="roles/iam.securityReviewer"
  gcloud organizations add-iam-policy-binding <orgID> --member="serviceAccount:mciem-service@gcp-oidc-entra-demo.iam.gserviceaccount.com" --role="roles/viewer"
```

We can now click Next and review and confirm.

![Image](/img/entra/entra-gcp-07.jpg)

Just like with onboarding an Azure Data Collector you can check on the status by going to the Data Collectors dashboard.

![Image](/img/entra/entra-gcp-08.jpg)

After a few minutes the status should have turned to Onboarded.

![Image](/img/entra/entra-gcp-09.jpg)

Now we can return to our Entra Permissions Management dashboard and we can see we are reciveving data not only from our Azure subscriptions but also from our Google proejcts as well. 

![Image](/img/entra/entra-gcp-10.jpg)

Just like that, in a matter of a few mintues we now have our Azure cloud and our Google cloud connected to Entra Permissions Management. We still have a lot of work to do but this is where it starts to get even more exiciting.

In future post I want to talk about the following topics for Entra Permissions Management:

* Discover & Assess
* Remediate & Manage
* Monitor & Alert
