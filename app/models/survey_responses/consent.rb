module SurveyResponses
  class Consent
    def stats(country)
      responses = SurveyResponse.consents.where(country: country)
      {
        All: responses.size,
        Consented: responses.where(consented: true).size,
        Unconsented: responses.where(consented: false).size
      }
    end
  end
end
