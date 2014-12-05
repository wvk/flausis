json.array!(@temperatures) do |temperature|
  json.extract! temperature, :id, :date, :min, :max, :avg, :station_id
  json.url temperature_url(temperature, format: :json)
end
