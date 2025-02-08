class NotesService
    def initialize(user, params)
      @user = user
      @params = params
    end
  
    def list_notes
      cache_key = "user_#{@user.id}_notes"  # Unique cache key for each user
    
      # Try to get cached notes from Redis
      cached_notes = REDIS.get(cache_key)
    
      if cached_notes
        Rails.logger.info "✅ Serving notes from Redis cache"
        return JSON.parse(cached_notes)  # Return cached data
      else
        Rails.logger.info "🔄 Fetching notes from DB and caching in Redis"
        notes = @user.notes.where(deleted: false)  # Fetch from DB
    
        # Store the notes in Redis with a unique cache key
        REDIS.set(cache_key, notes.to_json)
    
        # Set an expiration time for the cached notes (10 minutes)
        # REDIS.expire(cache_key, 10.minutes.to_i)
    
        return notes
      end
    end
    
    def create_note
      cache_key = "user_#{@user.id}_notes"
      note = @user.notes.build(@params)
      note.save ? { success: true, note: note } : { success: false, errors: note.errors.full_messages }
      Rails.logger.info "🔄 Clearing cache in Redis"
      REDIS.destroy(cache_key)
    end
  
    def update_note(note)
      if note.update(@params)
        { success: true, note: note }
      else
        { success: false, errors: note.errors.full_messages }
      end
    end
  
    def self.soft_delete_note(note)
        note.update(deleted: true ? false : true)
        if note.save
          { success: true, note: note }
        else
          { success: false, error: note.errors.full_messages }
        end
      end
  
    def archive(note)
      if note.update(is_archived: @params[:is_archived])
        { success: true, message: 'Note archived status updated successfully', note: note }
      else
        { success: false, errors: note.errors.full_messages }
      end
    end
  
    def change_color(note)
      if note.update(color: @params[:color])
        { success: true, message: 'Note color updated' }
      else
        { success: false, errors: note.errors.full_messages }
      end
    end
  
    def add_collaborator(note)
      email = @params[:email]
      return { success: false, error: 'Email is required' } unless email
  
      user = User.find_by(email: email)
      return { success: false, error: 'User not found' } unless user
  
      return { success: false, error: 'User is already a collaborator' } if note.collaborators.include?(user)
  
      note.collaborators << user
      { success: true, message: 'Collaborator added successfully', note: note }
    end
    
  end