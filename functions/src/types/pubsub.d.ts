// See https://cloud.google.com/functions/docs/writing/background#function_parameters

declare interface PubSubJson {
  message: PubSubMessage,
  subscription:string
}

declare interface PubSubMessage {
  data: string,
  messageId?:string
}

declare interface PubSubContext {
  eventId?: string,
  timestamp?: string,
  eventType?: string,
  resource?: object
}