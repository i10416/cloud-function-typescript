
# About
This repository is template for cloud functions in TypeScript and some additional GCP infrastructure resources.

You can manage GCP infrastructures by terraform in `/terraform` directory.
## Setup

### requirements
- python: python is rquired in order to install gcloud CLI.
- terraform: terraform CLI is required to configure, deploy and destroy GCP resources.
- node14.x: nodejs 14.x is required to compile `src/**/*.ts`
- gsutil: gsutil is required to create bucket.
### getting started

```bash
git clone path/to/repo
cd repo
```

### Install gcloud cli tool

check if python is already downloaded.
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

#### NOTE

##### debug


```bash
# LOGLEVEL= TRACE | DEBUG | INFO | WARN | ERROR
TF_LOG=<LOGLEVEL> terraform <command>

```

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

## Debug

### http trigger function

```
npx @google-cloud/functions-framework --target=helloHTTPFunction --source dist
```

### event trigger function
以下のコマンドでエミュレータを起動した後、別のタブからcurl で event の json を post する。 `console.log` は エミュレータが実行されているコンソールに出力される。

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

リクエストヘッダに↓のパラメタが付与されている場合、helloPubSubSubscriber の 引数 data には `-d` で渡された json object が、`context` には、`{ type: 'true', specversion: 'true', source: 'true', id: 'true' }` が入る。

```bash
-H "Ce-Type: true" \
  -H "Ce-Specversion: true" \
  -H "Ce-Source: true" \
  -H "Ce-Id: true" \
  -H "Content-Type: application/json" \
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
### gcloud のプロジェクトを切り替える(optional)
もし意図していないプロジェクトを使っていたら以下のコマンドでプロジェクトを切り替える。
```bash
gcloud config set project [PROJECT_ID]
```

### api を有効にする
```bash
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
```
### create service account for terraform

Create a service account for terraform named `YOUR_TERRAFORM_SERVICE_ACCOUNT_NAME`.

```bash
gcloud iam service-accounts create <YOUR_TERRAFORM_SERVICE_ACCOUNT_NAME> \
  --display-name "<DISPLAY NAME>"
```

### create GCP bucket BEFORE `terraform init` to avoid the chicken-egg problem

```bash
gsutil mb gs://BUCKET_NAME
```

change `terraform/backend.tf`

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
## resources の削除

```bash
terraform destroy
```

## Deploy(deprecated)
### http trigger function をデプロイする


※ `--allow-unauthenticated` はオプショナルなフラグ.

```bash
gcloud functions deploy <YOUR_FUNCTION_NAME> \
--runtime nodejs14 --region <YOUR_FUNCTION_REGION> --trigger-http --allow-unauthenticated \
--set-env-vars GCP_PROJECT=$(gcloud config get-value project)
```

#### http trigger function のテスト

```bash
curl "https://<REGION>-<PROJECT_ID>.cloudfunctions.net/<YOUR_FUNCTON_NAME>" 
```


### pubsub trigger function をデプロイする

Topic の作成

```bash
gcloud pubsub topics create MY_TOPIC
```

関数のデプロイ

※ `--trigger-topic` オプションで指定したトピックが存在しない場合、新しくその名前のトピックが作られる。
```bash
gcloud functions deploy <SUBSCRIBER_FUNC_NAME> --trigger-topic MY_TOPIC --runtime nodejs14 \
--region <YOUR_FUNC_REGION> --set-env-vars GCP_PROJECT=$(gcloud config get-value project)

```

#### cloud scheduler の設定
```bash
gcloud beta scheduler jobs create pubsub SCHEDULER_NAME \
--schedule '<cron schedule>' \
--topic MY_TOPIC \
--message-body '<MESSAGE>' \
--time-zone 'Asia/Tokyo'
```

#### pubsub trigger function のテスト


##### テスト環境

```bash
gcloud functions call <YOUR_PUBLISHER_FUNCTION_NAME> --data '{"topic":"MY_TOPIC","message":"Hello World!"}'
```

##### 本番環境
```bash
curl https://<FUNCTION_REGION>-<GCP_PROJECT_ID>.cloudfunctions.net/<YOUR_PUBLISHER_FUNCTION_NAME> -X POST  -d "{\"topic\": \"PUBSUB_TOPIC\", \"message\":\"YOUR_MESSAGE\"}" -H "Content-Type: application/json"
```


ログのチェック
```
gcloud functions logs read <YOUR_PUBLISHER_FUNCTION_NAME>
```


## リソース の削除

```bash
gcloud functions delete <YOUR_FUNCTION_NAME> 
gcloud beta scheduler jobs delete <YOUR_SCHEDULER_NAME>
gcloud pubsub topics delete <YOUR_TOPIC_NAME>
gcloud beta sql instances delete <YOUR_INSTANCE_NAME>
```