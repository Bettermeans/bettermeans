require 'spec_helper'

describe Delayed::Job do
  before  do
    Delayed::Worker.max_priority = nil
    Delayed::Worker.min_priority = nil

    Delayed::Job.delete_all
  end

  before(:each) do
    SimpleJob.runs = 0
  end

  it "should set run_at automatically if not set" do
    Delayed::Job.create(:payload_object => ErrorJob.new ).run_at.should_not == nil
  end

  it "should not set run_at automatically if already set" do
    later = 5.minutes.from_now
    Delayed::Job.create(:payload_object => ErrorJob.new, :run_at => later).run_at.should == later
  end

  it "should raise ArgumentError when handler doesn't respond_to :perform" do
    lambda { Delayed::Job.enqueue(Object.new) }.should raise_error(ArgumentError)
  end

  it "should increase count after enqueuing items" do
    Delayed::Job.enqueue SimpleJob.new
    Delayed::Job.count.should == 1
  end

  it "should be able to set priority when enqueuing items" do
    Delayed::Job.enqueue SimpleJob.new, 5
    Delayed::Job.first.priority.should == 5
  end

  it "should be able to set run_at when enqueuing items" do
    later = (Delayed::Job.db_time_now+5.minutes)
    Delayed::Job.enqueue SimpleJob.new, 5, later

    # use be close rather than equal to because millisecond values cn be lost in DB round trip
    Delayed::Job.first.run_at.should be_close(later, 1)
  end

  it "should work with jobs in modules" do
    job = Delayed::Job.enqueue M::ModuleJob.new
    lambda { job.invoke_job }.should change { M::ModuleJob.runs }.from(0).to(1)
  end

  it "should raise an DeserializationError when the job class is totally unknown" do

    job = Delayed::Job.new
    job['handler'] = "--- !ruby/object:JobThatDoesNotExist {}"

    lambda { job.payload_object.perform }.should raise_error(Delayed::DeserializationError)
  end

  it "should try to load the class when it is unknown at the time of the deserialization" do
    job = Delayed::Job.new
    job['handler'] = "--- !ruby/object:JobThatDoesNotExist {}"

    job.should_receive(:attempt_to_load).with('JobThatDoesNotExist').and_return(true)

    lambda { job.payload_object.perform }.should raise_error(Delayed::DeserializationError)
  end

  it "should try include the namespace when loading unknown objects" do
    job = Delayed::Job.new
    job['handler'] = "--- !ruby/object:Delayed::JobThatDoesNotExist {}"
    job.should_receive(:attempt_to_load).with('Delayed::JobThatDoesNotExist').and_return(true)
    lambda { job.payload_object.perform }.should raise_error(Delayed::DeserializationError)
  end

  it "should also try to load structs when they are unknown (raises TypeError)" do
    job = Delayed::Job.new
    job['handler'] = "--- !ruby/struct:JobThatDoesNotExist {}"

    job.should_receive(:attempt_to_load).with('JobThatDoesNotExist').and_return(true)

    lambda { job.payload_object.perform }.should raise_error(Delayed::DeserializationError)
  end

  it "should try include the namespace when loading unknown structs" do
    job = Delayed::Job.new
    job['handler'] = "--- !ruby/struct:Delayed::JobThatDoesNotExist {}"

    job.should_receive(:attempt_to_load).with('Delayed::JobThatDoesNotExist').and_return(true)
    lambda { job.payload_object.perform }.should raise_error(Delayed::DeserializationError)
  end

  it "should never find failed jobs" do
    @job = Delayed::Job.create :payload_object => SimpleJob.new, :attempts => 50, :failed_at => Delayed::Job.db_time_now
    Delayed::Job.find_available('worker', 1).length.should == 0
  end

  context "when another worker is already performing an task, it" do

    before :each do
      @job = Delayed::Job.create :payload_object => SimpleJob.new, :locked_by => 'worker1', :locked_at => Delayed::Job.db_time_now - 5.minutes
    end

    it "should not allow a second worker to get exclusive access" do
      @job.lock_exclusively!(4.hours, 'worker2').should == false
    end

    it "should allow a second worker to get exclusive access if the timeout has passed" do
      @job.lock_exclusively!(1.minute, 'worker2').should == true
    end

    it "should be able to get access to the task if it was started more then max_age ago" do
      @job.locked_at = 5.hours.ago
      @job.save

      @job.lock_exclusively! 4.hours, 'worker2'
      @job.reload
      @job.locked_by.should == 'worker2'
      @job.locked_at.should > 1.minute.ago
    end

    it "should not be found by another worker" do
      Delayed::Job.find_available('worker2', 1, 6.minutes).length.should == 0
    end

    it "should be found by another worker if the time has expired" do
      Delayed::Job.find_available('worker2', 1, 4.minutes).length.should == 1
    end

    it "should be able to get exclusive access again when the worker name is the same" do
      @job.lock_exclusively!(5.minutes, 'worker1').should be_true
      @job.lock_exclusively!(5.minutes, 'worker1').should be_true
      @job.lock_exclusively!(5.minutes, 'worker1').should be_true
    end
  end

  context "when another worker has worked on a task since the job was found to be available, it" do

    before :each do
      @job = Delayed::Job.create :payload_object => SimpleJob.new
      @job_copy_for_worker_2 = Delayed::Job.find(@job.id)
    end

    it "should not allow a second worker to get exclusive access if already successfully processed by worker1" do
      @job.delete
      @job_copy_for_worker_2.lock_exclusively!(4.hours, 'worker2').should == false
    end

    it "should not allow a second worker to get exclusive access if failed to be processed by worker1 and run_at time is now in future (due to backing off behaviour)" do
      @job.update_attributes(:attempts => 1, :run_at => 1.day.from_now)
      @job_copy_for_worker_2.lock_exclusively!(4.hours, 'worker2').should == false
    end
  end

  context "#name" do
    it "should be the class name of the job that was enqueued" do
      Delayed::Job.create(:payload_object => ErrorJob.new ).name.should == 'ErrorJob'
    end

    it "should be the method that will be called if its a performable method object" do
      Delayed::Job.send_later(:clear_locks!)
      Delayed::Job.last.name.should == 'Delayed::Job.clear_locks!'

    end
    it "should be the instance method that will be called if its a performable method object" do
      story = Story.create :text => "..."

      story.send_later(:save)

      Delayed::Job.last.name.should == 'Story#save'
    end
  end

  context "worker prioritization" do

    before(:each) do
      Delayed::Worker.max_priority = nil
      Delayed::Worker.min_priority = nil
    end

    it "should fetch jobs ordered by priority" do
      number_of_jobs = 10
      number_of_jobs.times { Delayed::Job.enqueue SimpleJob.new, rand(10) }
      jobs = Delayed::Job.find_available('worker', 10)
      ordered = true
      jobs[1..-1].each_index{ |i|
        if (jobs[i].priority < jobs[i+1].priority)
          ordered = false
          break
        end
      }
      ordered.should == true
    end

  end

  context "db_time_now" do
    it "should return time in current time zone if set" do
      Time.zone = 'Eastern Time (US & Canada)'
      Delayed::Job.db_time_now.zone.should == 'EST'
    end

    it "should return UTC time if that is the AR default" do
      Time.zone = nil
      ActiveRecord::Base.default_timezone = :utc
      Delayed::Job.db_time_now.zone.should == 'UTC'
    end

    it "should return local time if that is the AR default" do
      Time.zone = nil
      ActiveRecord::Base.default_timezone = :local
      Delayed::Job.db_time_now.zone.should_not == 'UTC'
    end
  end

end
