json.array!(@precipitations) do |precipitation|
  json.extract! precipitation, :id, :date, :amount, :station_id
  json.url precipitation_url(precipitation, format: :json)
end
