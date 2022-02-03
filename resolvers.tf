resource "aws_appsync_resolver" "Query_getTickets" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.tickets.name
  type        = "Query"
  field       = "getTickets"

  request_template = <<EOF
{
	"version" : "2018-05-29",
	"operation" : "Scan"
}
EOF
  response_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result.items)
EOF
}

resource "aws_appsync_function" "Mutation_addTicket_1" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.tickets.name
	name = "Mutation_addTicket_1"
  request_mapping_template = <<EOF
{
	"version" : "2018-05-29",
	"operation" : "PutItem",
	"key" : {
		"id": {"S": $util.toJson($util.autoId())}
	},
	"attributeValues": {
		#if(!$util.isNull($ctx.arguments.owner))
			"owner": {"S": $util.toJson($ctx.arguments.owner)},
		#end
		"title": {"S": $util.toJson($ctx.arguments.details.title)},
		"description": {"S": $util.toJson($ctx.arguments.details.description)},
		"severity": {"S": $util.toJson($ctx.arguments.details.severity)},
	}
}
EOF

  response_mapping_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_function" "Mutation_addTicket_2" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.tickets.name
	name = "Mutation_addTicket_2"
  request_mapping_template = <<EOF
{
	"version" : "2018-05-29",
	"operation" : "GetItem",
	"key" : {
		"id": {"S": $util.toJson($ctx.prev.result.id)}
	}
}
EOF

  response_mapping_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "Mutation_addTicket" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Mutation"
  field       = "addTicket"

  request_template = "{}"
  response_template = <<EOF
$util.toJson($ctx.result)
EOF
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.Mutation_addTicket_1.function_id,
      aws_appsync_function.Mutation_addTicket_2.function_id,
    ]
  }
}

resource "aws_appsync_function" "Ticket_attachments_1" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.images.name
	name = "Ticket_attachments_1"
  request_mapping_template = <<EOF
{
	"version" : "2018-05-29",
	"operation" : "Query",
	"query" : {
		"expression": "ticketid = :ticketid",
		"expressionValues" : {
			":ticketid" : $util.dynamodb.toDynamoDBJson($ctx.source.id)
		}
	},
	"index": "ticketid"
}
EOF
  response_mapping_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
#foreach($item in $ctx.result.items)
	$util.qr($item.put("__typename", "Image"))
#end
$util.toJson($ctx.result.items)
EOF
}

resource "aws_appsync_function" "Ticket_attachments_2" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.files.name
	name = "Ticket_attachments_1"
  request_mapping_template = <<EOF
{
	"version" : "2018-05-29",
	"operation" : "Query",
	"query" : {
		"expression": "ticketid = :ticketid",
		"expressionValues" : {
			":ticketid" : $util.dynamodb.toDynamoDBJson($ctx.source.id)
		}
	},
	"index": "ticketid"
}
EOF
  response_mapping_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
#foreach($item in $ctx.result.items)
	$util.qr($item.put("__typename", "File"))
#end
#foreach($item in $ctx.prev.result)
	$util.qr($ctx.result.items.add($item))
#end
$util.toJson($ctx.result.items)
EOF
}

resource "aws_appsync_resolver" "Ticket_attachments" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Ticket"
  field       = "attachments"

  request_template = "{}"
  response_template = <<EOF
$util.toJson($ctx.result)
EOF
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.Ticket_attachments_1.function_id,
      aws_appsync_function.Ticket_attachments_2.function_id,
    ]
  }
}

resource "aws_appsync_function" "Query_search_1" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.users.name
	name = "Query_search_1"
  request_mapping_template = <<EOF
{
	"version" : "2018-05-29",
	"operation" : "GetItem",
	"key": {
		"id": $util.dynamodb.toDynamoDBJson($ctx.arguments.query)
	},
	"consistentRead" : true
}
EOF
  response_mapping_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
$util.qr($ctx.result.put("__typename", "User"))
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_function" "Query_search_2" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.tickets.name
	name = "Query_search_1"
  request_mapping_template = <<EOF
#if(!$util.isNull($ctx.prev.result))
	#return($ctx.prev.result)
#end
{
	"version" : "2018-05-29",
	"operation" : "GetItem",
	"key": {
		"id": $util.dynamodb.toDynamoDBJson($ctx.arguments.query)
	},
	"consistentRead" : true
}
EOF
  response_mapping_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
$util.qr($ctx.result.put("__typename", "Ticket"))
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "Query_search" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "search"

  request_template = "{}"
  response_template = <<EOF
$util.toJson($ctx.result)
EOF
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.Query_search_1.function_id,
      aws_appsync_function.Query_search_2.function_id,
    ]
  }
}

resource "aws_appsync_resolver" "Ticket_owner" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.users.name
  type        = "Ticket"
  field       = "owner"

  request_template = <<EOF
#if($util.isNull($ctx.source.owner))
	#return
#end
{
	"version" : "2018-05-29",
	"operation" : "GetItem",
	"key": {
		"id": $util.dynamodb.toDynamoDBJson($ctx.source.owner)
	},
	"consistentRead" : true
}
EOF
  response_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "Mutation_deleteTicket" {
  api_id      = aws_appsync_graphql_api.appsync.id
  data_source = aws_appsync_datasource.tickets.name
  type        = "Mutation"
  field       = "deleteTicket"

  request_template = <<EOF
{
	"version" : "2018-05-29",
	"operation" : "DeleteItem",
	"key": {
		"id": $util.dynamodb.toDynamoDBJson($ctx.arguments.id)
	},
}
EOF
  response_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
#if($util.isNull($ctx.result))
#return
#end
$util.toJson($ctx.arguments.id)
EOF
}
