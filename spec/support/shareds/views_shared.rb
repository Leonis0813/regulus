# coding: utf-8

shared_context 'HTML初期化' do
  before(:all) { @html = nil }
end

shared_examples 'ヘッダーが表示されていること' do
  base_xpath =
    '//div[@class="navbar navbar-default navbar-static-top"]/div[@class="container"]'

  it do
    title_xpath = [base_xpath, 'span[@class="navbar-brand"]'].join('/')
    expect(@html).to have_selector(title_xpath, text: 'FX Rate Estimator')
  end

  ul_xpath = [
    base_xpath,
    'div[@class="navbar-collapse collapse navbar-responsive-collapse"]',
    'ul[@class="nav navbar-nav"]',
  ].join('/')

  [
    ['/analyses', '分析画面'],
    ['/predictions', '予測画面'],
  ].each do |href, text|
    it do
      expect(@html).to have_selector("#{ul_xpath}/li/a[@href='#{href}']", text: text)
    end
  end
end

shared_examples '表示件数情報が表示されていること' do |total: 0, from: 0, to: 0|
  it 'タイトルが表示されていること' do
    title = @html.xpath("#{table_panel_xpath}/h3")
    is_asserted_by { title.present? }
    is_asserted_by { title.text == 'ジョブ実行履歴' }
  end

  it '件数情報が表示されていること' do
    number = @html.xpath("#{table_panel_xpath}/h4")
    is_asserted_by { number.present? }
    is_asserted_by { number.text == "#{total}件中#{from}〜#{to}件を表示" }
  end
end

shared_examples 'ページングボタンが表示されていないこと' do
  it do
    paging = @html.xpath("#{table_panel_xpath}/nav/ul[@class='pagination']")
    is_asserted_by { paging.blank? }
  end
end

shared_examples 'ページングボタンが表示されていること' do |model: nil|
  it '先頭のページへのボタンが表示されていないこと' do
    is_asserted_by { @html.xpath(link_first_xpath).blank? }
  end

  it '前のページへのボタンが表示されていないこと' do
    is_asserted_by { @html.xpath(link_prev_xpath).blank? }
  end

  it '1ページ目が表示されていること' do
    link_one = @html.xpath(link_one_xpath)
    is_asserted_by { link_one.present? }
    is_asserted_by { link_one.text == '1' }
  end

  it '2ページ目へのリンクが表示されていること' do
    link_two = @html.xpath(link_two_xpath(model))
    is_asserted_by { link_two.present? }
    is_asserted_by { link_two.text == '2' }
  end

  it '次のページへのボタンが表示されていること' do
    link_next = @html.xpath(link_next_xpath(model))
    is_asserted_by { link_next.present? }
    is_asserted_by { link_next.text == I18n.t('views.pagination.next') }
  end

  it '最後のページへのボタンが表示されていること' do
    link_last = @html.xpath(link_last_xpath)
    is_asserted_by { link_last.present? }
    is_asserted_by { link_last.text == I18n.t('views.pagination.last') }
  end

  it '3点リーダが表示されていること' do
    list_gap = @html.xpath(list_gap_xpath)
    is_asserted_by { list_gap.present? }
    is_asserted_by { list_gap.text == '...' }
  end
end
