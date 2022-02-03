resource "aws_dynamodb_table" "tickets" {
  name           = "Tickets-${random_id.id.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "users" {
  name           = "Users-${random_id.id.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "images" {
  name           = "Images-${random_id.id.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  global_secondary_index {
    name            = "ticketid"
    hash_key        = "ticketid"
    projection_type = "ALL"
  }

  attribute {
    name = "ticketid"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "files" {
  name           = "Files-${random_id.id.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  global_secondary_index {
    name            = "ticketid"
    hash_key        = "ticketid"
    projection_type = "ALL"
  }

  attribute {
    name = "ticketid"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }
}

## sample data

resource "aws_dynamodb_table_item" "user1" {
  table_name = aws_dynamodb_table.users.name
  hash_key   = aws_dynamodb_table.users.hash_key
  range_key   = aws_dynamodb_table.users.range_key

  item = <<ITEM
{
  "id": {"S": "user1"},
  "name": {"S": "user1"}
}
ITEM
}

resource "aws_dynamodb_table_item" "user2" {
  table_name = aws_dynamodb_table.users.name
  hash_key   = aws_dynamodb_table.users.hash_key
  range_key   = aws_dynamodb_table.users.range_key

  item = <<ITEM
{
  "id": {"S": "user2"},
  "name": {"S": "user2"}
}
ITEM
}

resource "aws_dynamodb_table_item" "ticket1" {
  table_name = aws_dynamodb_table.tickets.name
  hash_key   = aws_dynamodb_table.tickets.hash_key
  range_key   = aws_dynamodb_table.tickets.range_key

  item = <<ITEM
{
  "id": {"S": "ticket1"},
	"title": {"S": "Ticket 1"},
	"description": {"S": "Description 1"},
	"owner": {"S": "user1"},
	"severity": {"S": "NORMAL"}
}
ITEM
}

resource "aws_dynamodb_table_item" "ticket2" {
  table_name = aws_dynamodb_table.tickets.name
  hash_key   = aws_dynamodb_table.tickets.hash_key
  range_key   = aws_dynamodb_table.tickets.range_key

  item = <<ITEM
{
  "id": {"S": "ticket2"},
	"title": {"S": "Ticket 2"},
	"description": {"S": "Description 2"},
	"severity": {"S": "CRITICAL"}
}
ITEM
}

resource "aws_dynamodb_table_item" "image1" {
  table_name = aws_dynamodb_table.images.name
  hash_key   = aws_dynamodb_table.images.hash_key
  range_key   = aws_dynamodb_table.images.range_key

  item = <<ITEM
{
  "ticketid": {"S": "ticket1"},
  "id": {"S": "image1"},
	"url": {"S": "example.com/image1.jpg"},
	"content_type": {"S": "image/jpg"}
}
ITEM
}

resource "aws_dynamodb_table_item" "file1" {
  table_name = aws_dynamodb_table.files.name
  hash_key   = aws_dynamodb_table.files.hash_key
  range_key   = aws_dynamodb_table.files.range_key

  item = <<ITEM
{
  "ticketid": {"S": "ticket1"},
  "id": {"S": "file1"},
	"url": {"S": "example.com/file.doc"},
	"size": {"N": "1500"}
}
ITEM
}

