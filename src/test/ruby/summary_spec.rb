require_relative '../../main/ruby/summary'
require_relative 'test_helpers'

describe Summary do

  before :each do
    @summary = Summary.new
  end

  describe "exit status" do

    it "succeeds if all tasks succeed" do
      @summary.task_started('server1', :task1)
      @summary.task_succeeded('server1', :task1)

      @summary.exit_status.should == 0
    end

    it "fails if one or more tasks fail" do
      @summary.task_started('server1', :task1)
      @summary.task_failed('server1', :task1, Exception.new)
      @summary.task_started('server2', :task1)
      @summary.task_succeeded('server2', :task1)

      @summary.exit_status.should_not == 0
      @summary.summary_table.should =~ /failed tasks/i
    end

    it "fails if no tasks were executed" do
      @summary.exit_status.should_not == 0
      @summary.summary_table.should =~ /no tasks/i
    end
  end

  describe "summary table content" do

    it "task is named exactly once, regardless of how many servers had it" do
      @summary.task_started('server1', :task1)
      @summary.task_succeeded('server1', :task1)
      @summary.task_started('server2', :task1)
      @summary.task_succeeded('server2', :task1)

      @summary.summary_table.should =~ /task1/m
      @summary.summary_table.should_not =~ /task1.*task1/m
    end

    it "server is named exactly once, regardless of how many tasks it had" do
      @summary.task_started('server1', :task1)
      @summary.task_succeeded('server1', :task1)
      @summary.task_started('server1', :task2)
      @summary.task_succeeded('server1', :task2)

      @summary.summary_table.should =~ /server1/m
      @summary.summary_table.should_not =~ /server1.*server1/m
    end

    it "shows succeeded tasks per server" do
      @summary.task_started('server1', :task1)
      @summary.task_succeeded('server1', :task1)

      @summary.summary_table.should =~ /OK/
    end

    it "shows failed tasks per server" do
      @summary.task_started('server1', :task1)
      @summary.task_failed('server1', :task1, Exception.new)

      @summary.summary_table.should =~ /FAILED/
    end

    it "shows skipped tasks per server" do
      @summary.task_skipped('server1', :task1)

      @summary.summary_table.should =~ /SKIPPED/
    end

    it "shows missing tasks per server" do
      @summary.task_started('server1', :task1)
      @summary.task_succeeded('server1', :task1)
      @summary.task_started('server2', :task2)
      @summary.task_succeeded('server2', :task2)

      rows = @summary.summary_table.lines.to_a
      rows[0].should =~ /task1.+task2/
      rows[1].should =~ /server1.+OK.+-/
      rows[2].should =~ /server2.+-.+OK/
    end
  end

  describe "summary table layout" do

    it "columns represent tasks" do
      @summary.task_started('any server', :task1)
      @summary.task_succeeded('any server', :task1)
      @summary.task_started('any server', :task2)
      @summary.task_succeeded('any server', :task2)

      rows = @summary.summary_table.lines.to_a
      rows[0].should =~ /task1.+task2/
    end

    it "rows represent servers" do
      @summary.task_started('server1', :any_task)
      @summary.task_succeeded('server1', :any_task)
      @summary.task_started('server2', :any_task)
      @summary.task_succeeded('server2', :any_task)

      rows = @summary.summary_table.lines.to_a
      rows[1].should =~ /server1/
      rows[2].should =~ /server2/
    end

    it "all columns are aligned, even when some names and statuses are longer than others" do
      @summary.task_started('shortname', :task)
      @summary.task_succeeded('shortname', :task)
      @summary.task_started('very_long_name', :task)
      @summary.task_failed('very_long_name', :task, Exception.new)

      rows = @summary.summary_table.lines.map { |s| s.rstrip }
      rows[0].should == "                task"
      rows[1].should == "shortname       OK"
      rows[2].should == "very_long_name  FAILED"
    end
  end
end
