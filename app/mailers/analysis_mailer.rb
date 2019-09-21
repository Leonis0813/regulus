# coding: utf-8

class AnalysisMailer < ApplicationMailer
  default from: 'Leonis.0813@gmail.com'

  def completed(analysis)
    @analysis = analysis
    subject = '分析が完了しました'
    tmp_dir = Rails.root.join('tmp', 'models', analysis.id.to_s)
    Rails.logger.info(tmp_dir)
    Dir.mktmpdir(nil, Rails.root.join('tmp', 'files')) do |dir|
      Rails.logger.info(dir)
      zip_file_name = File.join(dir, 'analysis.zip')

      Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip|
        Rails.logger.info(zip_file_name)
        Dir[File.join(tmp_dir, '*')].each do |file_name|
          file_name = File.basename(file_name)
          Rails.logger.info(file_name)
          zip.add(file_name, File.join(tmp_dir, file_name))
        end
      end
      Rails.logger.info(zip_file_name)
      attachments['analysis.zip'] = File.read(zip_file_name)
      mail(to: 'Leonis.0813@gmail.com', subject: subject, template_name: 'success')
    end
  end

  def error(analysis)
    @analysis = analysis
    subject = '分析中にエラーが発生しました'
    mail(to: 'Leonis.0813@gmail.com', subject: subject, template_name: 'failer')
  end
end
