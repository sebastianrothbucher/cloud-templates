import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import serverlessExpress from '@vendia/serverless-express'
import { Callback, Context, Handler } from 'aws-lambda';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  if (!process.env.LAMBDA_TASK_ROOT) {
    await app.listen(3000);
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

