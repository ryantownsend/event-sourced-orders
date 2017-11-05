require 'racecar'
require 'oj'
require_relative '../models/order'

class OrderConsumer < Racecar::Consumer
  subscribes_to "#{ENV['KAFKA_PREFIX']}orders", start_from_beginning: true

  def process(message)
    message_value = Oj.load(message.value)

    order = Order.where(id: message_value.fetch('order_id')).first_or_create!({
      line_items: message_value.fetch('line_items'),
      created_at: message_value.fetch('timestamp'),
      total: message_value.fetch('line_items').map { |li|
        Integer(li['price']) * Integer(li['quantity'])
      }.reduce(:+)
    })
  end
end
