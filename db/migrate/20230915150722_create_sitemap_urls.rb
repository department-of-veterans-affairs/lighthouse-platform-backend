class CreateSitemapUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :sitemap_urls do |t|
      t.string :url, null: false

      t.timestamps
    end
  end
end
