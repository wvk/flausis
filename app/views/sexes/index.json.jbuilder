json.array!(@sexes) do |sex|
  json.extract! sex, :id, :name
  json.url sex_url(sex, format: :json)
end
