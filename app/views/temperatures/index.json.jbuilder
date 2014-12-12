json.array!(@temperatures) do |temperature|
  json.extract! temperature, :id, :timestamp, :value
  json.url temperature_url(temperature, format: :json)
end
