# regulus

**application for estimating currency movement**

## Directory Structure

    CHANGELOG.md
    Gemfile
    README.md
    Rakefile
    app   -- assets      -- images
                         -- javascripts               -- confirmation.coffee
                                                      -- excanvas.min.js
                                                      -- jqplot.dateAxisRenderer.min.js
                                                      -- jqplot.ohlcRenderer.min.js
                                                      -- jquery.jqplot.min.js
                                                      -- jquery.min.js
                                                      -- ...
                         -- stylesheets               -- confirmation.scss
                                                      -- jquery.jqplot.min.css
                                                      -- ...
          -- controllers -- confirmation_controller.rb
                         -- ...
          -- helpers     -- confirmation_helper.rb
                         -- ...
          -- mailers
          -- models      -- article.rb
                         -- currency.rb
                         -- tweet.rb
                         -- ...
          -- views       -- confirmation              -- show.html.erb
                                                      -- update_article.js.erb
                                                      -- update_currency.js.erb
                                                      -- update_tweet.js.erb
                         -- layouts                   -- ...
    bin    -- ...
    config               -- environments              -- ...
                         -- initializers              -- ...
                         -- ...
    config.ru
    db     -- migrate    -- ...
           -- ...
    lib    -- ...
    log    -- ...
    public -- ...
    script -- Gemfile
           -- currency.rb
           -- nikkei.rb
           -- tweet.rb
           -- update_currencies.rb
           -- update_nikkei.rb
           -- update_tweets.rb
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
    vendor -- assets      -- ...

## Requirement

- MySQL
- Application registration for Twitter API

## DB

- Currencies Table

|Column Name  |Type     |Description                            |
|:------------|:--------|:--------------------------------------|
|time         |datetime |the time which got currency info       |
|pair         |varchar  |currency pair code                     |
|bid          |float    |bid price of the currency              |
|ask          |float    |ask price of the currency              |
|open         |float    |open price of the currency             |
|high         |float    |high price of the currency             |
|low          |float    |low price of the currency              |

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
