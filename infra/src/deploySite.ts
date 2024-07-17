import CF from 'aws-sdk/clients/cloudformation';
import AWS from 'aws-sdk';
import { ExecOptions, exec } from 'child_process';
import chalk from 'chalk';

async function deploySite() {
    const cf = new CF({
        region: 'us-east-1',
    });
    const result = await cf.describeStacks({
        StackName: 'AmazonIVSRTWebDemoStack',
    }).promise();
    const stacks = result.Stacks || [];
    for (const stack of stacks) {
        const outputs = stack.Outputs || [];
        const apiUrl = outputs.find((o) => o.OutputKey == 'apiUrl')?.OutputValue;
        const siteBucketName = outputs.find((o) => o.OutputKey == 'siteBucketName')?.OutputValue;
        const appUrl = outputs.find((o) => o.OutputKey == 'appUrl')?.OutputValue;

        if (siteBucketName != null && apiUrl != null) {
            console.log('\n');
            console.log(chalk.blue('Building site....'));
            console.log('\n');
            const code = await execute(`API_URL=${apiUrl} npm run build`, {
                cwd: '../',
            });
            if (code == 0) {
                console.log('\n');
                console.log(chalk.yellow('Uploading site to s3....'));
                console.log('\n');
                const uploadExitCode = await execute(`aws s3 cp ../dist s3://${siteBucketName}/ --recursive`);
                if (uploadExitCode == 0) {
                    console.log('\n');
                    console.log(chalk.green(`Successfuly deployed app!`))
                    console.log(chalk.green(`Site Url: ${appUrl}`))
                }
            } else {
                console.error(`Build failed with code ${code}`);
            }
        } else {
            console.log('No site bucket name found.');
        }
    }

}

function execute(command: string, options?: ExecOptions | null | undefined): Promise<number> {
    return new Promise((resolve, reject) => {
        const p = exec(command, options)
        p.stdout?.on('data', (data) => {
            singleLineLog(data);
        })

        p.on('exit', (code) => {
            if (code != null) {
                resolve(code);
            } else {
                reject('exit code is unexpectedly null');
            }
        });
    });
}

function singleLineLog(log: string) {
    process.stdout.write(`${log}\r`);
}

deploySite();