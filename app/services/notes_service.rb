class NotesService
    def initialize(user, params)
      @user = user
      @params = params
    end
  
    def list_notes
      @user.notes.where(deleted: false)
    end
  
    def create_note
      note = @user.notes.build(@params)
      note.save ? { success: true, note: note } : { success: false, errors: note.errors.full_messages }
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