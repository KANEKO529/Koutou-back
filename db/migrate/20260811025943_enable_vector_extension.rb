class EnableVectorExtension < ActiveRecord::Migration[8.0]
  def change
    enable_extension "extensions.vector"
  end
end
