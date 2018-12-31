# coding: utf-8
class AnalysisMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'

  def finished(analysis, is_success)
    @analysis = analysis
    subject = is_success ? '分析が完了しました' : '分析中にエラーが発生しました'
    template_name = is_success ? 'success' : 'failer'
    tmp_dir = File.join(Rails.root, "tmp/models/#{analysis.id}")

    Dir.mktmpdir(nil, File.join(Rails.root, 'tmp/files')) do |dir|
      zip_file_name = File.join(dir, 'analysis.zip')

      Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip|
        Dir[File.join(tmp_dir, '*')].each do |file_name|
          file_name = File.basename(file_name)
          zip.add(file_name, File.join(tmp_dir, file_name))
        end
      end

      attachments['analysis.zip'] = File.read(zip_file_name)
      mail(:to => 'Leonis.0813@gmail.com', :subject => subject, :template_name => template_name)
    end
  end
end
