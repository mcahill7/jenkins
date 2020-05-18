## Creating Pipeline
To create the pipeline run the following 
```aws cloudformation create-stack --stack-name jenkins-pipeline --template-body file://pipeline/pipeline.yaml --capabilities CAPABILITY_NAMED_IAM```

To update the pipeline run the following
```aws cloudformation update-stack --stack-name jenkins-pipeline --template-body file://pipeline/pipeline.yaml --capabilities CAPABILITY_NAMED_IAM```