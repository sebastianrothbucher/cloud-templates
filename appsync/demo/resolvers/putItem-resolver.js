import { util } from "@aws-appsync/utils";

/**
 * Puts an item into the DynamoDB table using an auto-generated ID.
 * @param {import('@aws-appsync/utils').Context<{listid, title}>} ctx the context
 * @returns {import('@aws-appsync/utils').DynamoDBPutItemRequest} the request
 */
export function request(ctx) {
  return {
    operation: "PutItem",
    key: util.dynamodb.toMapValues({ listid: ctx.args.listid, 'ts-uuid': '' + util.time.nowEpochMilliSeconds() + '-' + util.autoId() }), // have a predictable yet unique range key
    attributeValues: util.dynamodb.toMapValues({
        title: ctx.args.title,
        done: false,
    }),
  };
}

/**
 * Returns the item or throws an error if the operation failed
 * @param {import('@aws-appsync/utils').Context} ctx the context
 * @returns {{listid, ts_uuid, title, done}} the inserted item
 */
export function response(ctx) {
  if (ctx.error) {
    util.error(ctx.error.message, ctx.error.type);
  }
  return {
      listid: ctx.result['listid'],
      ts_uuid: ctx.result['ts-uuid'],
      title: ctx.result['title'],
      done: ctx.result['done'],
  };
}
