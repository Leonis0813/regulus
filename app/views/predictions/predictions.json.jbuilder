json.predictions do
  json.array!(@predictions) do |prediction|
    json.(
      prediction,
      :prediction_id,
      :model,
      :from,
      :to,
    )
    json.(prediction.analysis, :pair)
    json.(
      prediction,
      :means,
      :result,
      :state,
      :created_at,
    )
  end
end
