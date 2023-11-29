class EmailObserver
  def self.delivered_email(message)
    EmailLog.create(recipient: message.to.to_s, subject: message.subject.to_s,
                    message: message.body.to_s)
  end
end

Rails.application.configure do
  config.action_mailer.observers = %w[EmailObserver]
end
