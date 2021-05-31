# frozen_string_literal: true

class MailSenderJob < ApplicationJob
  queue_as :default

  # send to all list with state passive & subscribed
  def perform(campaign)
    campaign.apply_premailer
    campaign
      .available_segments
      .where.not(email: nil).find_each do |app_user|
      campaign.push_notification(app_user)
    end

    campaign.state = "sent"
    campaign.save
    campaign.broadcast_event
  end
end
