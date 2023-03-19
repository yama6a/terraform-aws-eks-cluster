module "sqs_event_subscriptions" {
  count = length(var.subscriptions)

  source                  = "../eventbridge_sqs_destination_subscription"
  tags                    = var.tags
  subscriber_service_name = var.subscriber_service_name

  event_bus_name         = var.subscriptions[count.index].event_bus_name
  event_name             = var.subscriptions[count.index].event_name
  messageGroupId         = var.subscriptions[count.index].messageGroupId
  subscription_queue_arn = aws_sqs_queue.subscription_queue.arn
}


// Subscription queue for events
// We use a FIFO queue for two reasons (despite lower throughput - which is still easily good enough)
// 1) FIFO queues guarantee exactly-once-delivery, which removes the deduplication-burden from the message receiver.
// 2) FIFO queues allow us to peg a messageGroupID to messages, which we can use in case a service needs
//     to subscribe to the same event more than once, by letting the subscriber know which subscription a message
//     belongs to, leveraging the messageGroupID field (see messageGroupId above in the subscription TF module).
resource "aws_sqs_queue" "subscription_queue" {
  name       = "${var.subscriber_service_name}__events.fifo"
  tags       = var.tags
  fifo_queue = true

  // this allows a message to appear multiple times and not get deduplicated, as long as they have different message groups.
  deduplication_scope         = "messageGroup"
  content_based_deduplication = true

  // 14 days (maximum allowed by AWS) - in case service id taken offline for a few days for a migration or so, it can keep consuming as soon as it's back online
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = 30
    // implement exponential backoff on the receiver side!!
  })
}

// DLQ for undelivered messages
resource "aws_sqs_queue" "dead_letter_queue" {
  name       = "${var.subscriber_service_name}__events__DLQ.fifo"
  tags       = var.tags
  fifo_queue = true

  // this allows a message to appear multiple times and not get deduplicated, as long as they have different message groups.
  deduplication_scope         = "messageGroup"
  content_based_deduplication = true

  // 14 days (maximum allowed by AWS) - results in total 28 days of retention (14 days for the main queue + 14 days for the DLQ)
  message_retention_seconds = 1209600
}

// Allow the EventBridge to send messages to the SQS queue.
resource "aws_sqs_queue_policy" "eventbridge_to_sqs_policy" {
  queue_url = aws_sqs_queue.subscription_queue.id

  policy = jsonencode({
    Version : "2012-10-17",
    Id : "sqspolicy",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "events.amazonaws.com"
        },
        Action : "sqs:SendMessage",
        Resource : aws_sqs_queue.subscription_queue.arn,
        Condition : {
          "ForAnyValue:ArnEquals" : {
            "aws:SourceArn" : module.sqs_event_subscriptions[*].event_rule_arn
          }
        }
      }
    ]
  })
}

// Allow a SA that has this policy pegged to it, to:
// 1. Receive messages and see basic queue info
// 2. Delete messages (after successful consumption)
// 3. Put messages back onto the queue with a modified VisibilityTimeout (to implement a backoff for failed messages)
resource "aws_iam_policy" "consumer_policy" {
  name = "${var.subscriber_service_name}-sqs-event-subscriber-policy"
  tags = var.tags

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Action : [
          "sqs:ChangeMessageVisibility",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:DeleteMessage",
          "sqs:DeleteMessageBatch",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ],
        Resource = [
          aws_sqs_queue.subscription_queue.arn,
          aws_sqs_queue.dead_letter_queue.arn
        ]
      },
    ]
  })
}
