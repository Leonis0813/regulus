class AddAnalysisIdToAnalyses < ActiveRecord::Migration[5.0]
  def change
    add_column :analyses, :analysis_id, :string, after: :id

    Analysis.where(analysis_id: nil).each do |analysis|
      analysis.analysis_id = SecureRandom.hex
      analysis.save(validate: false)
    end

    add_index :analyses, :analysis_id, unique: true
  end
end
