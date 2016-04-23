# regulus

**application for estimating currency movement**

## Directory Structure

    CHANGELOG.md
    Gemfile
    README.md
    Rakefile
    app    -- assets      -- images
                          -- javascripts               -- application.js
                                                       -- articles.coffee
                                                       -- rates.coffee
                                                       -- tweets.coffee
                          -- stylesheets               -- application.css
                                                       -- rates.scss
                                                       -- tab.scss
                                                       -- tweets.scss
           -- controllers -- application_controller.rb
                          -- articles_controller.rb
                          -- rates_controller.rb
                          -- tweets_controller.rb
           -- helpers     -- application_helper.rb
           -- mailers
           -- models      -- article.rb
                          -- rate.rb
                          -- tweet.rb
                          -- ...
           -- views       -- articles                  -- show.html.erb
                                                       -- update.js.erb
                          -- rates                     -- show.html.erb
                                                       -- update.js.erb
                          -- tweets                    -- show.html.erb
                                                       -- update.js.erb
                          -- layouts                   -- ...
    bin    -- ...
    config                -- environments              -- ...
                          -- initializers              -- ...
                          -- ...
    config.ru
    db     -- migrate     -- ...
           -- ...
    lib    -- ...
    log    -- ...
    public -- ...
    script -- Gemfile
           -- articles.copy.rb
           -- articles.import.rb
           -- rates.aggregate.rb
           -- rates.aggregate.sql
           -- rates.copy.rb
           -- rates.delete.rb
           -- rates.dump.rb
           -- rates.import.rb
           -- tweets.copy.rb
           -- tweets.delete.rb
           -- tweets.dump.rb
           -- tweets.import.rb
    spec   -- ...
    test   -- controllers -- confirmation_controller_test.rb
           -- fixtures    -- articles.yml
                          -- currencies.yml
                          -- tweets.yml
           -- models      -- article_test.rb
                          -- currency_test.rb
                          -- tweet_test.rb
           -- ...
    tmp    -- cache       -- assets                    -- development -- sass -- ...
                                                       -- sprockets   -- ...
           -- pids        -- ...
           -- sessions
           -- sockets
    vendor -- assets      -- javascripts               -- d3.min.js

## Requirement

- MySQL
- Application registration for Twitter API

## DB

- Ratess Table

|Column Name  |Type     |Description                            |
|:------------|:--------|:--------------------------------------|
|from_date    |datetime |oldest time between the interval       |
|to_date      |datetime |newest time between the interval       |
|pair         |varchar  |currency pair code                     |
|interval     |varchar  |aggregating period                     |
|open         |float    |first price of the currency            |
|close        |float    |last price of the currency             |
|high         |float    |maximum price of the currency          |
|low          |float    |minimum price of the currency          |

- Tweets Table

|Column Name       |Type     |Description                   |
|:-----------------|:--------|:-----------------------------|
|tweet_id          |varchar  |tweet_id                      |
|user_name         |varchar  |user name of the tweet        |
|profile_image_url |varchar  |profile image url of the user |
|full_text         |text     |full text of the tweet        |
|tweeted_at        |datetime |tweeted time                  |
|created_at        |datetime |registered time of the tweet  |

- Articles Table

|Column Name |Type     |Description                     |
|:-----------|:--------|:-------------------------------|
|published   |datetime |published time of the article   |
|title       |varchar  |title of the article            |
|summary     |text     |summary of the article          |
|url         |varchar  |url to full text of the article |
|created_at  |datetime |registered time of the article  |
