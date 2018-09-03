describe "Basic Unit Tests" do

  it "creates a start and end time for a day" do
    day = UIState.mk_day(2018, 9, 2, 7, 30, 22, 0)
    day.should.equal [Time.new(2018, 9, 2, 7, 30), Time.new(2018, 9, 2, 22, 0)]
  end

  it "has the correct defaults for a day" do
    # What the heck - Time.new returns a different month!
    #(main)> xx=Time.new(2018, 9, 16)
    #=> 2018-10-16 00:00:00 -0400
    UIState.default_day(Time.new(2018, 9, 16), 0).should.equal(
        [
          Time.new(2018, 10, 10, 8, 0),
          Time.new(2018, 10, 10, 17, 0)
        ])
  end

  it "generates a humanized version of how much time worked" do
    UIState.interval_string(60 * 60).should.equal("1 hour")
    UIState.interval_string((60 * 60) + 60).should.equal('1 hour 1 min')
    UIState.interval_string((60 * 60) + (15 * 60)).should.equal('1 hour 15 mins')
    UIState.interval_string(2 * 60 * 60).should.equal("2 hours")
    UIState.interval_string((2 * 60 * 60) + 60).should.equal('2 hours 1 min')
    UIState.interval_string((2 * 60 * 60) + (15 * 60)).should.equal('2 hours 15 mins')
  end
end