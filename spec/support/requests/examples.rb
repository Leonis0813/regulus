# coding: utf-8

shared_examples 'レート画面にリダイレクトされていること' do
  it { expect(current_url).to eq("#{Capybara.app_host}/rates") }
end

shared_examples 'リンクの状態が正しいこと' do |selected_link|
  [['レート', '/rates'], ['ツイート', '/tweets'], ['記事', '/articles']].each do |text, path|
    it "'#{text}'へのリンクが表示されていること" do
      condition = path.match(/#{selected_link}/) ? 'selected' : 'not-selected'
      expect(page).to have_selector("a[href='#{path}'][class='#{condition}']", :text => text)
    end
  end
end

shared_examples 'セレクトボックスの状態が正しいこと' do |pair, interval|
  [pair, interval].each do |selected|
    it { expect(page).to have_xpath("//form/select/option[text()='#{selected}'][@selected]") }
  end
end

shared_examples '表示されているデータが正しいこと' do |content, id|
  it "#{content}が表示されていること" do
    expect(page).to have_selector("div##{id}")
  end
end
