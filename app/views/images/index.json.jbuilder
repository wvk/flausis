json.array!(@images) do |image|
  json.extract! image, :id, :filename, :date, :time, :annotations
  json.url image_url(image, format: :json)
end
