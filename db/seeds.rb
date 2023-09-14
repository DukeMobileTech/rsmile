# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

countries = %w[Brazil Kenya Vietnam]
# 1ST 7 buckets
groups = ['non-binary', 'transgender women', 'transgender men', 'multi-attracted women',
          'multi-attracted men', 'women attracted to women', 'men attracted to men',
          'lesbian women', 'gay men', 'bisexual / pansexual women', 'bisexual / pansexual men', 'no group', 'ineligible']

def digit
  Random.rand(0...9)
end

def letter
  ('A'..'Z').to_a.sample
end

User.create(email: 'user@example.com', password: 'Password1!', admin: true)

10.times do
  p = Participant.create(
    email: Faker::Internet.email,
    phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    country: countries.sample,
    self_generated_id: "#{countries.sample[0]}-#{Random.rand(0...99)}-#{digit}-#{digit}-#{letter}#{letter}#{letter}",
    rds_id: "#{countries.sample[0]}-#{Random.rand(10_000...99_999)}-#{[1, 2].sample}",
    study_id: "#{countries.sample[0]}-#{Random.rand(10_000...99_999)}",
    code: "#{countries.sample[0]}-#{Random.rand(10_000...99_999)}",
    referrer_code: "#{countries.sample[0]}-#{Random.rand(10_000...99_999)}",
    sgm_group: groups.sample,
    referrer_sgm_group: groups.sample,
    match: [true, false].sample,
    quota: digit
  )
  SurveyResponse.create(
    participant_id: p.id,
    survey_uuid: SecureRandom.uuid,
    response_uuid: SecureRandom.uuid,
    survey_complete: [true, false].sample
  )
end
