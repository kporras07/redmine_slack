# frozen_string_literal: true

# Slack notification model class.
class RedmineSlackNotification < ActiveRecord::Base
  def self.find_or_create(entity, entity_id)
    notification = RedmineSlackNotification.find_by(entity: entity, entity_id: entity_id)
    unless notification
      notification = RedmineSlackNotification.new
      notification.entity = entity
      notification.entity_id = entity_id
      notification.timestamp = Time.now.to_i
    end

    notification
  end

  def self.find_or_create_within_timeframe(entity, entity_id, seconds)
    current_timestamp = Time.now.to_i
    timestamp = current_timestamp - seconds.to_i
    notification = RedmineSlackNotification.find_by(
      'entity = ? AND entity_id = ? AND timestamp >= ?',
      entity,
      entity_id,
      timestamp
    )
    unless notification
      notification = RedmineSlackNotification.new
      notification.entity = entity
      notification.entity_id = entity_id
      notification.timestamp = current_timestamp
    end
    notification
  end

  def self.find_notification_by_type_within_timeframe(entity, seconds)
    current_timestamp = Time.now.to_i
    timestamp = current_timestamp - seconds.to_i
    notifications = RedmineSlackNotification.where(
      'entity = ? AND timestamp >= ?',
      entity,
      timestamp
    )
    notifications
  end
end
