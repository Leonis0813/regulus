# coding: utf-8

class AnalysisMailer < ApplicationMailer
  include ModelUtil

  default from: 'Leonis.0813@gmail.com'

  def completed(analysis)
    @analysis = analysis
    subject = '分析が完了しました'
    tmp_dir = Rails.root.join('tmp', 'models', analysis.id.to_s)

    Dir.mktmpdir(nil, Rails.root.join('tmp', 'files')) do |dir|
      zipfile_path = File.join(dir, 'analysis.zip')
      zip_model(tmp_dir, zipfile_path)
      attachments['analysis.zip'] = File.read(zipfile_path)
      mail(to: 'Leonis.0813@gmail.com', subject: subject, template_name: 'success')
    end
  end

  def error(analysis)
    @analysis = analysis
    subject = '分析中にエラーが発生しました'
    mail(to: 'Leonis.0813@gmail.com', subject: subject, template_name: 'failer')
  end
end
