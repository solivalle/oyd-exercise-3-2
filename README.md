# Currency Converter Lambda Deployment

This project deploys an AWS Lambda function exposed through API Gateway using Terraform. The Lambda provides two endpoints:

- `GET /rates` → Returns available exchange rates
- `POST /convert` → Converts an amount between currencies

---

## Deployment Process

The Lambda package was built locally and the infrastructure was provisioned using Terraform.

### Build Lambda Package

```bash
cd app/ && zip function.zip index.js && cd ..
```

### Apply Terraform Infrastructure

```bash
cd infra/ && terraform apply -var-file=envs/dev/dev.tfvars
```

---

## Lambda Function Details

The Lambda function information was retrieved with the following command:

```bash
aws lambda get-function \
 --function-name <your-function-name> \
 --query '{FunctionArn:Configuration.FunctionArn,State:Configuration.State,Arch:Configuration.Architectures}'
```

The evidence file was saved at:

```text
infra/evidence/function.txt
```

Inline reference to the evidence file:

```bash
cat infra/evidence/function.txt
```

---

## API Endpoint Validation

The API Gateway invoke URL was obtained using:

```bash
INVOKE_URL=$(cd infra && terraform output -raw invoke_url)
```

### Test `GET /rates`

Command executed:

```bash
curl ${INVOKE_URL}/rates
```

Expected response:

```json
{
  "rates": {
    "USD": 1,
    "EUR": 0.92,
    "GBP": 0.79,
    "JPY": 149.5,
    "GTQ": 7.78
  }
}
```

### Test `POST /convert`

Command executed:

```bash
curl -X POST ${INVOKE_URL}/convert \
  -H 'Content-Type: application/json' \
  -d '{"from":"USD","to":"GTQ","amount":100}'
```

Expected response:

```json
{
  "from": "USD",
  "to": "GTQ",
  "amount": 100,
  "result": 778
}
```

---

## Captured Lambda Responses

The command outputs from the endpoint validation tests were saved in:

```text
infra/evidence/lambda-response.txt
```

Inline contents of `lambda-response.txt`:

```text
sergio@Sergios-MacBook-Pro infra % echo $INVOKE_URL
https://1aw2qmkzd3.execute-api.us-west-2.amazonaws.com/

sergio@Sergios-MacBook-Pro infra % curl ${INVOKE_URL}/rates
{"rates":{"USD":1,"EUR":0.92,"GBP":0.79,"JPY":149.5,"GTQ":7.78}}%

sergio@Sergios-MacBook-Pro infra % curl ${INVOKE_URL}/convert \
-H 'Content-Type: application/json' \
-d '{"from":"USD","to":"GTQ","amount":100}'

{"from":"USD","to":"GTQ","amount":100,"result":778}%
```

---

## Evidence

- `infra/evidence/function.txt`
- `infra/evidence/lambda-response.txt`

---

## Resource Cleanup

After validating the deployment and collecting all evidence, the infrastructure was destroyed with:

```bash
terraform destroy -var-file=envs/dev/dev.tfvars
```