require 'spec_helper'

describe ReportsController, '#issue_report' do

  integrate_views

  let(:project) { Factory.create(:project) }
  let(:tracker) { project.trackers.first }
  let(:issue_status) { Factory.create(:issue_status) }

  context 'when params[:detail] is "tracker"' do
    let(:valid_params) { { :detail => 'tracker', :id => project.id  } }

    it 'assigns @field' do
      get(:issue_report, valid_params)
      assigns(:field).should == 'tracker_id'
    end

    it 'assigns @rows' do
      get(:issue_report, valid_params)
      assigns(:rows).should == project.trackers
    end

    it 'assigns @data' do
      Factory.create(:issue, {
        :tracker => tracker,
        :status => issue_status,
        :project => project,
      })
      get(:issue_report, valid_params)
      assigns(:data).should == [{
        'status_id' => issue_status.id.to_s,
        'closed' => 'f',
        'total' => '1',
        'tracker_id' => tracker.id.to_s,
      }]
    end

    it 'assigns @report_title' do
      get(:issue_report, valid_params)
      assigns(:report_title).should == I18n.t(:field_tracker)
    end

    it 'renders the template "issue_report_details"' do
      get(:issue_report, valid_params)
      response.should render_template('reports/issue_report_details')
    end
  end

end
