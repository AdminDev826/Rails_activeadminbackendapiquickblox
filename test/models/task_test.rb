require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  def setup
    @task = tasks(:one)
  end

  def test_valid
    assert @task.valid?
  end

  test "task has name, description, date, price, user_id as attributes" do
    assert_equal("TestName1", @task.name)
    assert_equal("Test description text", @task.description)
    # assert_equal("2015-08-17 19:02:16", @task.date)
    assert_equal(1000, @task.price)
  end
end
