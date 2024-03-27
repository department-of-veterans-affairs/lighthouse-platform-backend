class AddDataToNews < ActiveRecord::Migration[7.0]
  def up
    NewsCategory.create(call_to_action: 'Read the articles',
                        description: 'Articles related to developers, APIs, the developer portal, and Veterans.',
                        media: false,
                        title: 'Articles'
                        )
    NewsCategory.create(call_to_action: 'Read the news releases',
                        description: 'Press releases from the Department of Veterans Affairs related to Lighthouse.',
                        media: false,
                        title: 'News releases'
                        )
    NewsCategory.create(call_to_action: 'Access digital media',
                        description: 'Audio and video related to developers, APIs, Veterans, and the Department of Veterans Affairs.',
                        media: true,
                        title: 'Digital media'
                        )
  end
end
