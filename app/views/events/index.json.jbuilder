json.array!(@events) do |event|
  json.extract! event, :id, :species_id, :sex_id, :precipitation_id, :temperature_id, :event_type_id, :image_id
  json.url event_url(event, format: :json)
end
