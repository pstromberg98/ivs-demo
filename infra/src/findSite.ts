import CF from 'aws-sdk/clients/cloudformation';

console.log('Finding site...');

// console.log(bucket.bucketName);

async function findSite() {
    const cf = new CF({
        region: 'us-east-1',
    });
    const result = await cf.describeStacks({
        StackName: 'AmazonIVSRTWebDemoStack',
    }).promise();
    const stacks = result.Stacks || [];
    console.log('Found Stacks:')
    for (const stack of stacks) {
        const outputs = stack.Outputs || [];
        const appUrl = outputs.find((o) => o.OutputKey == 'appUrl');
        const apiUrl = outputs.find((o) => o.OutputKey == 'apiUrl');
        console.log(`App Url: ${appUrl?.OutputValue}`)
        console.log(`Api Url: ${apiUrl?.OutputValue}`)
    }
}

findSite();