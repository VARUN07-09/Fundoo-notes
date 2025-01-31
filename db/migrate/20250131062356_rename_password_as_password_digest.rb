class RenamePasswordAsPasswordDigest < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :password_digest) # Prevent duplicate column creation
      add_column :users, :password_digest, :string
    end
  end

end
