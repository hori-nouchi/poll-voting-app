json.extract! diary, :id, :diary_date, :color, :content, :created_at, :updated_at
json.url diary_url(diary, format: :json)
