json.predictions do
  json.array!(@predictions) do |prediction|
    json.(
      prediction,
      :prediction_id,
      :model,
      :from,
      :to,
      :pair,
      :means,
      :result,
      :state,
      :created_at,
    )
  end
end
