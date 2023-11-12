import { util } from "@aws-appsync/utils";

/**
 * Queries a DynamoDB table for items based on the `id` and that contain the `tag`
 * @param {import('@aws-appsync/utils').Context<{listid: string}>} ctx the context
 * @returns {import('@aws-appsync/utils').DynamoDBQueryRequest} the request
 */
export function request(ctx) {
  const query = JSON.parse(
    util.transform.toDynamoDBConditionExpression({
      listid: { eq: ctx.args.listid },
    }),
  );
  return { operation: "Query", query };
}

/**
 * Returns the query items
 * @param {import('@aws-appsync/utils').Context} ctx the context
 * @returns {{listid, items: {listid, ts_uuid, title, done}}} a flat list of result items
 */
export function response(ctx) {
  if (ctx.error) {
    util.error(ctx.error.message, ctx.error.type);
  }
  return {
      listid: ctx.args.listid,
      items: ctx.result.items.map(item => ({
          listid: item['listid'],
          ts_uuid: item['ts-uuid'],
          title: item['title'],
          done: item['done'],
      }))
  };
}
