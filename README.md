
# About

## Setup

### getting started

```bash
git clone path/to/repo
cd repo
```

### Install gcloud cli tool

check if python is already downloaded.

```bash
cd ~
```

```bash
python --version
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
npm install
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

## compile

```bash
npm run compile
```

## terraform

### install terraform

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update && sudo apt-get install terraform
```

In case GPG error:
See https://ebc-2in2crc.hatenablog.jp/entry/2020/01/22/120432


### gcloud のアカウントを確認・設定する

```
gcloud config list
```

```
gcloud auth login
```

### gcloud のプロジェクトを切り替える

```bash
gcloud config set project [PROJECT_ID]
```

### create service account for terraform

```bash
gcloud iam service-accounts create terraform-serviceaccount \
  --display-name "Account for Terraform"
```

### create bucket BEFORE `terraform init` to avoid chicken-egg problem


### create service account and configure policy

```bash
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member serviceAccount:terraform-serviceaccount@$(gcloud config get-value project).iam.gserviceaccount.com \
  --role roles/editor
```

### generate credentials as account.json

```bash
 gcloud iam service-accounts keys create ./terraform/account.json \
  --iam-account terraform-serviceaccount@$(gcloud config get-value project).iam.gserviceaccount.com
```

### before deploy

```bash
terraform plan
```


## Deploy

```bash
npm run compile
terraform apply
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