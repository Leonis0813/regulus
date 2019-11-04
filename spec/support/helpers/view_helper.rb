module ViewHelper
  def row_xpath
    '//div[@id="main-content"]/div[@class="row center-block"]'
  end

  def paging_xpath
    [table_panel_xpath, 'nav', 'ul[@class="pagination"]'].join('/')
  end

  def link_first_xpath
    [paging_xpath, 'li[@class="pagination"]', 'span[@class="first"]', 'a'].join('/')
  end

  def link_prev_xpath
    [paging_xpath, 'li[@class="pagination"]', 'span[@class="prev"]', 'a'].join('/')
  end

  def link_one_xpath
    [paging_xpath, 'li[@class="page-item active"]', 'a[@class="page-link"]'].join('/')
  end

  def link_two_xpath(model)
    [
      paging_xpath,
      'li[@class="page-item"]',
      "a[@class='page-link'][@href='/#{model.pluralize}?page=2']",
    ].join('/')
  end

  def link_next_xpath(model)
    [
      paging_xpath,
      'li[@class="page-item"]',
      'span[@class="next"]',
      "a[@class='page-link'][@href='/#{model.pluralize}?page=2']",
    ].join('/')
  end

  def link_last_xpath
    [paging_xpath, 'li[@class="page-item"]', 'span[@class="last"]', 'a'].join('/')
  end

  def list_gap_xpath
    [paging_xpath, 'li[@class="page-item disabled"]', 'a[@href="#"]'].join('/')
  end

  def table_panel_xpath
    [row_xpath, 'div[@class="col-lg-8 well"]'].join('/')
  end

  module_function :table_panel_xpath, :row_xpath
end
