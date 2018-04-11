module UploadToCloud

  #####
  # Method to upload task image to the cloud

  def task_image_upload(task_id, image)

    init_storage

    directory = @storage.directories.get("snaptask_images")
    uid = SecureRandom.urlsafe_base64(nil, false)

    file = directory.files.create(
      :key    => "task_images/#{task_id}/img_#{uid}.jpg",
      :content_type => 'image/jpeg',
      :body   => Base64.decode64(image),
      :public => true
    )
    link = "https://storage.googleapis.com/snaptask_images/#{file.key}"

    puts link.inspect
    return link
  end

  #####
  # Method to upload user avatar image

  def user_avatar_upload(user_id, image)

    init_storage    

    directory = @storage.directories.get("snaptask_images")
    uid = SecureRandom.urlsafe_base64(nil, false)

    file = directory.files.create(
      :key    => "user_avatars/#{user_id}/img_#{uid}.jpg",
      :content_type => 'image/jpeg',
      :body   => Base64.decode64(image),
      :public => true
    )
    link = "https://storage.googleapis.com/snaptask_images/#{file.key}"
    puts link.inspect
    return link
  end

  #####
  # Method to upload portfolio image to the cloud

  def portfolio_image_upload(user_id, image)
    
    init_storage

    directory = @storage.directories.get("snaptask_images")
    uid = SecureRandom.urlsafe_base64(nil, false)

    file = directory.files.create(
      :key    => "portfolio_images/#{user_id}/img_#{uid}.jpg",
      :content_type => 'image/jpeg',
      :body   => Base64.decode64(image),
      :public => true
    )
    link = "https://storage.googleapis.com/snaptask_images/#{file.key}"
    puts link.inspect
    return link
  end

  #####
  # Method to upload category image to the cloud

  def category_image_upload(category_id, image)
    
    init_storage

    directory = @storage.directories.get("snaptask_images")
    uid = SecureRandom.urlsafe_base64(nil, false)

    file = directory.files.create(
      :key    => "category_images/#{category_id}/img_#{uid}.jpg",
      :content_type => 'image/jpeg',
      :body   => Base64.decode64(image),
      :public => true
    )
    link = "https://storage.googleapis.com/snaptask_images/#{file.key}"
    puts link.inspect
    return link
  end

  def init_storage
    @storage = Fog::Storage.new({
        :provider => "Google",
        :google_project=>  'snaptask-1016',
        :google_client_email=> '1096869330758-6s66s8mm77qb5tbacd20v0jbtm65rdpi@developer.gserviceaccount.com',
        :google_json_key_location => Rails.root.to_s+'/private/gcs.json',
        :google_storage_secret_access_key=> '0d0c5yVaxAuwJoEp/Nj9XtApyAwj3vdBHWvVcpfk',
        :google_storage_access_key_id => 'GOOG7JFGYPKRKIQI4SC2',
        :fog_directory => 'snaptask_images'
      })
  end


end
