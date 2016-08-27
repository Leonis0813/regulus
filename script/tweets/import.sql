INSERT INTO
  tweets
VALUES (
  '$ID', "$USER_NAME", '$PROFILE_IMAGE_URL', "$FULL_TEXT", '$TWEETED_AT', '$CREATED_AT'
)
ON DUPLICATE KEY UPDATE
  user_name = VALUES(user_name),
  profile_image_url = VALUES(profile_image_url),
  full_text = VALUES(full_text)
