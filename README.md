
# About
This repository is a template for cloud functions in TypeScript and some additional GCP infrastructure resources.

This template is useful in such a case as you want to recurringly start and stop cloudsql instances so that you can save money.

If you want to control GCP resources from cloud functions, see https://github.com/googleapis/google-api-nodejs-client 

You can set up and manage GCP infrastructures by terraform in `/terraform` directory.
## Setup

### requirements
- python: python is rquired to install gcloud CLI.
- terraform: terraform CLI is required to configure, deploy and destroy GCP resources.
- node14.x: nodejs 14.x is required to compile `src/**/*.ts`
- gsutil: gsutil is required to create bucket.
### getting started

```bash
git clone path/to/repo
cd repo
```

### Install gcloud cli tool

check if python is already installed.
```bash
python --version
```


```bash
cd ~
```


download tar.gz

```bash
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-329.0.0-linux-x86_64.tar.gz
```

unzip tar.gz and init client SDK

```bash
tar -zxvf google-cloud-sdk-329.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
./google-cloud-sdk/bin/gcloud init
```

### Install dependencies

```bash
node -v
# => v14.x.x
npm -v
# 6.14.x

npm install
```

### install terraform

#### for linux
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update && sudo apt-get install terraform

# restart bash and check if terraform is successfully installed.
terraform --version
# ask how to use terraform cli
terraform --help
```

In case GPG error:
See https://ebc-2in2crc.hatenablog.jp/entry/2020/01/22/120432
#### for macOS

```bash
brew install tfenv
tfenv -v
# => tfenv 1.0.1

# list available terraform versions
tfenv list
tfenv install x.x.x
tfenv use x.x.x
```

#### NOTE

##### debug

```bash
# LOGLEVEL= TRACE | DEBUG | INFO | WARN | ERROR
TF_LOG=<LOGLEVEL> terraform <command>

```

## Debug

`@google-cloud/functions-framework` helps developers locally debug and test cloud functions. `npx @google-cloud/functions-framework` boots a cloud functions emulator and stdout logs are displayed in the bash window where the emulator is running.

About functions-framework, see https://github.com/GoogleCloudPlatform/functions-framework-nodejs
### http trigger function

```
npx @google-cloud/functions-framework --target=helloHTTPFunction --source dist
curl -X GET http://localhost:8080
```

### event trigger function

```
npx @google-cloud/functions-framework --target=helloPubSubSubscriber --signature-type=event  --source dist
```

```
curl -d "@example/event_example.json" \
  -X POST \
  -H "Ce-Type: true" \
  -H "Ce-Specversion: true" \
  -H "Ce-Source: true" \
  -H "Ce-Id: true" \
  -H "Content-Type: application/json" \
  http://localhost:8080

```

## before deploy
### compile

```bash
npm run compile
```


### gcloud のアカウントを確認・設定する


```bash
gcloud auth login
```

```bash
gcloud config list
```

#### create a project(optional) 
```bash
gcloud projects create <project_name>
```
### switch gcloud project(optional)
もし意図していないプロジェクトを使っていたら以下のコマンドでプロジェクトを切り替える。
```bash
gcloud config set project [PROJECT_ID]
```

### enable APIs
```bash
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
```
### create a service account for terraform if not exists

Run command below to create a service account for terraform named `YOUR_TERRAFORM_SERVICE_ACCOUNT_NAME`.

```bash
gcloud iam service-accounts create <YOUR_TERRAFORM_SERVICE_ACCOUNT_NAME> \
  --display-name "<DISPLAY NAME>"
```

### create GCP bucket BEFORE `terraform init` to avoid the chicken-egg problem

```bash
gsutil mb gs://<BUCKET_NAME>
```

Change `terraform/backend.tf`

```diff
terraform {
  backend "gcs" {
-    bucket = "sample-terraform-state-store"
+    bucket = "<BUCKET_NAME>"
  }
}

```

### configure service account policy

```bash
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member serviceAccount:<YOUR_TERRAFORM_SERVICE_ACCOUNT_NAME>@$(gcloud config get-value project).iam.gserviceaccount.com \
  --role roles/editor
```

### generate credentials as account.json

```bash
 gcloud iam service-accounts keys create ./terraform/account.json \
  --iam-account <YOUR_TERRAFORM_SERVICE_ACCOUNT_NAME>@$(gcloud config get-value project).iam.gserviceaccount.com
```

### init terraform

```bash
cd terraform
terraform init
terraform validate
terraform fmt
terraform plan
```


## Deploy

```bash
terraform apply
```

## check resources

```bash
gcloud beta scheduler jobs list
gcloud functions list
gcloud pubsub topics list
```

#### テスト環境


```bash
# http
npx @google-cloud/functions-framework --target=helloWorld

curl -X GET http://localhost:8080

# pubsub
gcloud functions call <YOUR_PUBLISHER_FUNCTION_NAME> --data '{"topic":"MY_TOPIC","message":"Hello World!"}'
```

#### 本番環境
```bash
# http trigger
curl "https://<REGION>-<PROJECT_ID>.cloudfunctions.net/<YOUR_FUNCTON_NAME>" 

# pubsub trigger
curl https://<FUNCTION_REGION>-<GCP_PROJECT_ID>.cloudfunctions.net/<YOUR_PUBLISHER_FUNCTION_NAME> -X POST  -d "{\"topic\": \"PUBSUB_TOPIC\", \"message\":\"YOUR_MESSAGE\"}" -H "Content-Type: application/json"
```

## check logs

```bash
gcloud functions logs read <YOUR_PUBLISHER_FUNCTION_NAME>
```

## delete resources

```bash
terraform destroy
```