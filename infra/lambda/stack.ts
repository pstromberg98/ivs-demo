import {
  CfnOutput,
  Duration,
  RemovalPolicy,
  Stack,
  StackProps,
} from "aws-cdk-lib";
import {
  Cors,
  LambdaIntegration,
  RestApi,
  RequestValidator,
  Model,
  JsonSchemaType,
} from "aws-cdk-lib/aws-apigateway";
import { AttributeType, BillingMode, Table } from "aws-cdk-lib/aws-dynamodb";
import { Effect, PolicyStatement } from "aws-cdk-lib/aws-iam";
import { Runtime } from "aws-cdk-lib/aws-lambda";
import { NodejsFunction } from "aws-cdk-lib/aws-lambda-nodejs";
import {
  Rule as EventRule,
  Schedule as EventSchedule,
} from "aws-cdk-lib/aws-events";
import { LambdaFunction, LambdaFunction as TargetLambdaFunction } from "aws-cdk-lib/aws-events-targets";
import { Construct } from "constructs";
import { DDBTableName } from "./constants";
import { BucketDeployment, Source } from "aws-cdk-lib/aws-s3-deployment";
import { BlockPublicAccess, Bucket } from "aws-cdk-lib/aws-s3";
import S3 from 'aws-sdk/clients/S3';

import path from "path";
import { CloudFrontWebDistribution, Function, FunctionCode, FunctionEventType, FunctionRuntime } from "aws-cdk-lib/aws-cloudfront";
import { Distribution, FunctionAssociation, CfnFunction } from "aws-cdk-lib/aws-cloudfront";
import { ConfigurationSource, SourcedConfiguration } from "aws-cdk-lib/aws-appconfig";
import { S3Origin } from "aws-cdk-lib/aws-cloudfront-origins";

function getPolicy(): PolicyStatement {
  return new PolicyStatement({
    effect: Effect.ALLOW,
    actions: ["ivs:*"],
    resources: ["*"],
  });
}

class AmazonIVSRTWebDemoStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    const initialPolicy = [getPolicy()];
    const runtime = Runtime.NODEJS_18_X;
    const bundling = {
      /**
       * By default, when using the NODEJS_18_X runtime, @aws-sdk/* is included in externalModules
       * since it is already available in the Lambda runtime. However, to ensure that the latest
       * @aws-sdk version is used, which contains the @aws-sdk/client-ivs-realtime package, we
       * remove @aws-sdk/* from externalModules so that we bundle it instead.
       */
      externalModules: [],
      minify: true,
    };
    const environment = { TABLE_NAME: DDBTableName };
    const timeout = Duration.minutes(1);

    const stagesTable = new Table(this, DDBTableName, {
      tableName: DDBTableName,
      partitionKey: {
        name: "sessionId",
        type: AttributeType.STRING,
      },
      billingMode: BillingMode.PAY_PER_REQUEST,
      removalPolicy: RemovalPolicy.DESTROY,
    });

    const createFunction = new NodejsFunction(
      this,
      "AmazonIVSRTWebDemoCreateFunction",
      {
        entry: "lambda/createHandler.ts",
        handler: "createHandler",
        initialPolicy,
        runtime,
        bundling,
        environment,
        timeout,
      },
    );

    const cleanupFunction = new NodejsFunction(
      this,
      "AmazonIVSRTWebDemoCleanupFunction",
      {
        entry: "lambda/cleanupHandler.ts",
        handler: "cleanupHandler",
        initialPolicy,
        runtime,
        bundling,
        environment,
        timeout,
      },
    );

    const stageJoinFunction = new NodejsFunction(
      this,
      "AmazonIVSRTWebDemoJoinFunction",
      {
        entry: "lambda/stageJoinHandler.ts",
        handler: "stageJoinHandler",
        initialPolicy,
        runtime,
        bundling,
        environment,
        timeout,
      },
    );

    // Allow lambda handlers to access DynamoDB
    stagesTable.grantReadWriteData(createFunction);
    stagesTable.grantReadWriteData(cleanupFunction);
    stagesTable.grantReadData(stageJoinFunction);

    const api = new RestApi(this, "AmazonIVSRTWebDemoApi", {
      defaultCorsPreflightOptions: {
        allowOrigins: Cors.ALL_ORIGINS,
        allowMethods: ["POST", "DELETE"],
        allowHeaders: Cors.DEFAULT_HEADERS,
      },
    });

    const createModel = new Model(this, "create-model-validator", {
      restApi: api,
      contentType: "application/json",
      description: "Model used to validate body of create requests.",
      modelName: "createModelCdk",
      schema: {
        type: JsonSchemaType.OBJECT,
        required: ["userId", "attributes"],
        properties: {
          userId: { type: JsonSchemaType.STRING },
          attributes: { type: JsonSchemaType.OBJECT },
        },
      },
    });

    const createRequestValidator = new RequestValidator(
      this,
      "create-request-validator",
      {
        restApi: api,
        requestValidatorName: "create-request-validator",
        validateRequestBody: true,
      },
    );

    const createPath = api.root.addResource("create");
    createPath.addMethod("POST", new LambdaIntegration(createFunction), {
      requestValidator: createRequestValidator,
      requestModels: {
        "application/json": createModel,
      },
    });

    const joinModel = new Model(this, "join-model-validator", {
      restApi: api,
      contentType: "application/json",
      description: "Model used to validate body of join requests.",
      modelName: "joinModelCdk",
      schema: {
        type: JsonSchemaType.OBJECT,
        required: ["sessionId", "userId", "attributes"],
        properties: {
          sessionId: { type: JsonSchemaType.STRING },
          userId: { type: JsonSchemaType.STRING },
          attributes: { type: JsonSchemaType.OBJECT },
        },
      },
    });

    const joinRequestValidator = new RequestValidator(
      this,
      "join-request-validator",
      {
        restApi: api,
        requestValidatorName: "join-request-validator",
        validateRequestBody: true,
      },
    );

    const joinPath = api.root.addResource("join");
    joinPath.addMethod("POST", new LambdaIntegration(stageJoinFunction), {
      requestValidator: joinRequestValidator,
      requestModels: {
        "application/json": joinModel,
      },
    });

    // Clean up stages with no users every minute
    const eventRule = new EventRule(this, "scheduleRule", {
      schedule: EventSchedule.rate(Duration.minutes(1)),
    });
    eventRule.addTarget(new TargetLambdaFunction(cleanupFunction));

    const unpublishedFunction = new NodejsFunction(this, "AmazonIVSRTWebDemoUnpublishedFunction", {
      entry: "lambda/unpublishHandler.ts",
      handler: "unpublishHandler",
      initialPolicy,
      runtime,
      bundling,
      environment,
      timeout,
    });
    const unpublishedEventRule = new EventRule(this, "unpublishedRule", {
      eventPattern: {
        detailType: ['IVS Stage Update'],
        source: ['aws.ivs']
      }
    });
    unpublishedEventRule.addTarget(new TargetLambdaFunction(unpublishedFunction));

    // S3 and CloudFront
    const bucket = new Bucket(this, 'site-bucket', {
      removalPolicy: RemovalPolicy.DESTROY,
      blockPublicAccess: BlockPublicAccess.BLOCK_ACLS,
      publicReadAccess: true,
      autoDeleteObjects: true,
    });
    const publicPolicy = new PolicyStatement({
      sid: "PublicReadGetObject",
      effect: Effect.ALLOW,
      actions: ["s3:GetObject"],
      resources: [`arn:aws:s3:::${bucket.bucketName}/*`]
    });
    bucket.addToResourcePolicy(publicPolicy)
    publicPolicy.addAnyPrincipal()

    const indexRedirectFunction = new Function(this, 'site-distribution-index-function', {
      functionName: 'indexRedirectFunction',
      code: FunctionCode.fromInline(cfnIndexCode),
      runtime: FunctionRuntime.JS_2_0,
    });

    const cfDistribution = new Distribution(this, 'site-distribution', {
      defaultBehavior: {
        functionAssociations: [
          {
            function: indexRedirectFunction,
            eventType: FunctionEventType.VIEWER_REQUEST,
          },
        ],
        origin: new S3Origin(bucket),
      }
    });

    new CfnOutput(this, 'site-distribution-url', {
      value: cfDistribution.distributionDomainName,
      key: 'appUrl',
    })

    new CfnOutput(this, 'site-bucket-name', {
      value: bucket.bucketName,
      key: 'siteBucketName',
    })

    new CfnOutput(this, 'api-url', {
      value: api.url,
      key: 'apiUrl',
    })
  }
}

var cfnIndexCode = `
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    console.log(uri)
    
    // Check whether the URI is missing a file name.
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } 
    // Check whether the URI is missing a file extension.
    else if (!uri.includes('.')) {
        request.uri = '/index.html';
    }

    return request;
}
`

export default AmazonIVSRTWebDemoStack;
