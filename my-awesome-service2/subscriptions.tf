locals {
  subscription_webhook_url = "https://webhook.site/61c099f1-5566-4658-b4a9-8458e61a4764"

  // For now, every service can only subscribe to each event maximum once. That is because we only have one
  // pre-determined wehbook URL. If we want to have multiple subscriptions to the same event, we need to have
  // multiple webhook URLs or multiple queues to listen to, which we haven't implemented yet. When we find a fix,
  // check out the "rule_suffix" variable in the "eventbridge_subscription" module to create unique rules for
  // the same subscription.
  subscriptions = [
    {
      event_bus_name = "my-awesome-service2"
      event_name     = "Service2Event"
    },
    {
      event_bus_name = "my-awesome-service"
      event_name     = "AnimalCreatedEvent"
    },
  ]
}

module "event_subscription_Service2Event" {
  count = length(local.subscriptions)

  source                               = "../module/service_resources/module/eventbridge_subscription"
  tags                                 = local.tags
  aws_region                           = var.aws_region
  event_subscriber_connection_arn      = var.event_subscriber_connection_arn
  event_subscriber_connection_role_arn = var.event_subscriber_connection_role_arn
  subscriber_service_name              = var.service_name
  api_destination_arn                  = aws_cloudwatch_event_api_destination.dst.arn

  depends_on = [
    time_sleep.wait_30_seconds
  ]

  event_bus_name = local.subscriptions[count.index].event_bus_name
  event_name     = local.subscriptions[count.index].event_name
}

resource "aws_cloudwatch_event_api_destination" "dst" {
  name                             = var.service_name
  description                      = "API Destination for ${var.service_name} to consume events"
  invocation_endpoint              = local.subscription_webhook_url
  http_method                      = "POST"
  invocation_rate_limit_per_second = 10
  connection_arn                   = var.event_subscriber_connection_arn
}

// After the event bus of this service is created, we need to wait for a few seconds, giving terraform more time to
// create all other event busses that this service might depend on. Ugly hack, but ¯\_(ツ)_/¯ it works.
resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.event_publisher
  ]

  create_duration = "30s"
}
