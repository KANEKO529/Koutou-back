class ChangeSectionNameNullableInFeaturedArticles < ActiveRecord::Migration[8.0]
  def change
    change_column_null :featured_articles, :section_name, true
  end
end
