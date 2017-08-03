module Exporter
  module ExcelExporter
    def self.export_paper_ranking(paper)
      enrolls = paper.enrolls.finished.includes(user: [:organizations]).order(score: :desc)

      p = Axlsx::Package.new
      p.workbook.add_worksheet(name: 'Sheet 1') do |sheet|
        sheet.add_row ['排名', '姓名', '得分', '公司名称']

        enrolls.each_with_index do |enroll, i|
          sheet.add_row [i + 1, enroll.user.name, enroll.score, enroll.user.organizations.first.name]
        end
      end
      p.use_shared_strings = true
      p.to_stream.read
    end

    def self.export_individual_ranking(period)
      users = User.includes(:organizations).order_by_score_for(period)

      p = Axlsx::Package.new
      p.workbook.add_worksheet(name: 'Sheet 1') do |sheet|
        sheet.add_row ['排名', '姓名', '参考次数', '总得分', '公司名称']

        users.each.with_index do |user, i|
          enrolls = case period
                    when :week
                      user.enrolls.current_week
                    when :month
                      user.enrolls.current_month
                    when :quarter
                      user.enrolls.current_quarter
                    end

          num_of_references = enrolls.count
          score = enrolls.sum(:score)

          sheet.add_row [i + 1, user.name, num_of_references, score, user.organizations.first.name]
        end
      end
      p.use_shared_strings = true
      p.to_stream.read
    end

    def self.export_company_ranking(period)
      orgs = Organization.order_by_score_for(period)

      p = Axlsx::Package.new
      p.workbook.add_worksheet(name: 'Sheet 1') do |sheet|
        sheet.add_row ['排名', '公司名称', '参考次数', '总得分']

        orgs.each.with_index do |org, i|
          enrolls = Enroll.where(user_id: org.user_ids)
          enrolls = case period
                    when :month
                      enrolls.current_month
                    when :quarter
                      enrolls.current_quarter
                    end

          num_of_references = enrolls.count
          score = enrolls.sum(:score)

          sheet.add_row [i + 1, org.name, num_of_references, score]
        end
      end
      p.use_shared_strings = true
      p.to_stream.read
    end
  end
end
