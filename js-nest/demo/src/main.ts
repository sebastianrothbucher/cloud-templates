import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import serverlessExpress from '@vendia/serverless-express'
import { Callback, Context, Handler } from 'aws-lambda';
import { APP_VERSION } from './version';

async function bootstrap() {
  const port = process.env.PORT || 3000;
  console.log('Starting version ' + APP_VERSION + ' on port ' + port);
  const app = await NestFactory.create(AppModule);
  if (!process.env.LAMBDA_TASK_ROOT) {
    await app.listen(port);
  } else {
    await app.init();
    return serverlessExpress({ app: app.getHttpAdapter().getInstance() });
  }
}

if (!process.env.LAMBDA_TASK_ROOT) {
  bootstrap();
}
// now for lambda
let server;
export const handler: Handler = async (
  event: any,
  context: Context,
  callback: Callback,
) => {
  if (!process.env.LAMBDA_TASK_ROOT) {
    throw 'We need to be lambda!'
  }
  server = server ?? (await bootstrap());
  return server(event, context, callback);
};

