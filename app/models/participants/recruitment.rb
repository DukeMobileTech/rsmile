module Participants
  class Recruitment
    def stats(country)
      stats = {}
      id = Participant.eligible.where(country: country).order(created_at: :desc).first&.id
      key = "#{country}/#{id}/recruitment"
      Rails.cache.fetch(key, expires_in: 24.hours) do
        participants = Participant.eligible.where(country: country)
        stats[:eligible] = participants.size
        stats[:intersex] = participants.select{|p| p.intersex == 'Yes'}.size
        stats
      end
    end
  end
end
