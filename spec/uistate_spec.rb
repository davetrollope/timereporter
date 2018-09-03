describe UIState do
  describe "Basic Unit Tests" do
    class MockStorage
      def initialize(dataset=:static_only)
        @dataset = dataset
      end

      def load_static_data
        return nil if @dataset == :init

        {
            'reporting_email' => 'test@mock.com',
            'current_week' => 'Sep 16, 2018',

            # Needed when presenting a dialog and a screen rotation occurs
            'day_of_week' => 0,
            'time_type' => nil,
            'start_hour' => 8,
            'start_minute' => 0
        }
      end

      def load_week_data(week_id)
        return { week: nil, daytime: nil } if @dataset != :week

        {
            week: [
                [Time.new(2018, 8, 10, 8, 0), Time.new(2018, 8, 10, 17, 0)],
                [Time.new(2018, 8, 11, 9, 0), Time.new(2018, 8, 10, 16, 0)],
                [Time.new(2018, 8, 12, 10, 0), Time.new(2018, 8, 10, 16, 0)],
                [Time.new(2018, 8, 13, 11, 0), Time.new(2018, 8, 10, 15, 0)],
                [Time.new(2018, 8, 14, 12, 30), Time.new(2018, 8, 10, 15, 30)],
                [Time.new(2018, 8, 15, 8, 0), Time.new(2018, 8, 10, 17, 0)],
                [Time.new(2018, 8, 16, 8, 0), Time.new(2018, 8, 10, 17, 0)],
            ],
            day_state: [
                :working, nil, :working, nil, :working, nil, nil
            ],
            daytime: nil,
            week_id: 'Sep 16, 2018',
            end_time: Time.new(2018, 8, 16),
        }
      end
    end
    class MockActivity
      attr_accessor :storage

      def initialize(storage)
        @storage = storage
      end
    end

    MONTH = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    it "can be created with default state" do
      activity = MockActivity.new(MockStorage.new(:init))
      uistate = UIState.new(activity)

      uistate.activity.should.equal activity
      UIState.current.should.equal uistate
      uistate.reporting_email.should.equal ''

      current_week_end = uistate.current_week_end
      current_week_end.wday.should.equal(0)

      current_week_end.to_s.should.equal uistate.end_time.to_s
      end_time = uistate.end_time
      end_string = "#{end_time.day} #{MONTH[end_time.month - 1]}"

      uistate.static_hash.should.equal(
          {
              reporting_email: '',
              current_week: uistate.current_week_id,
              day_of_week: nil,
              time_type: nil,
              start_hour: nil,
              start_minute: nil
          }
      )
      uistate.week_hash.should.equal(
          {
              week_end: uistate.current_week_id,
              days: [{:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "Off", :state => nil},
                     {:text => "Off", :state => nil},
                     {:text => end_string, :state => nil},
                     {:text => "Send", :state => nil}
              ]
          }
      )

    end

    it "can be created with static state" do
      activity = MockActivity.new(MockStorage.new)
      uistate = UIState.new(activity)

      uistate.activity.should.equal activity
      UIState.current.should.equal uistate
      uistate.reporting_email.should.equal 'test@mock.com'

      uistate.current_week_id.should.equal 'Sep 16, 2018'

      uistate.static_hash.should.equal(
          {
              reporting_email: uistate.reporting_email,
              current_week: uistate.current_week_id,
              day_of_week: 0,
              time_type: nil,
              start_hour: 8,
              start_minute: 0
          }
      )
      uistate.week_hash.should.equal(
          {
              week_end: uistate.current_week_id,
              days: [{:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "08:00 - 17:00", :state => :working},
                     {:text => "Off", :state => nil},
                     {:text => "Off", :state => nil},
                     {:text => "16 September", :state => nil},
                     {:text => "Send", :state => nil}
              ]
          }
      )
    end

    it "can be created with state data for a loaded week" do
      activity = MockActivity.new(MockStorage.new(:week))
      uistate = UIState.new(activity)

      uistate.activity.should.equal activity
      UIState.current.should.equal uistate
      uistate.reporting_email.should.equal 'test@mock.com'

      uistate.current_week_id.should.equal 'Sep 16, 2018'

      uistate.static_hash.should.equal(
          {
              reporting_email: uistate.reporting_email,
              current_week: uistate.current_week_id,
              day_of_week: 0,
              time_type: nil,
              start_hour: 8,
              start_minute: 0
          }
      )
      uistate.week_hash.should.equal(
          {
              week_end: uistate.current_week_id,
              days: [{:text => "08:00 - 17:00", :state => :working},
                     {:text => "Off", :state => nil},
                     {:text => "10:00 - 16:00", :state => :working},
                     {:text => "Off", :state => nil},
                     {:text => "12:30 - 15:30", :state => :working},
                     {:text => "Off", :state => nil},
                     {:text => "Off", :state => nil},
                     {:text => "16 September", :state => nil},
                     {:text => "Send", :state => nil}
              ]
          }
      )
    end

  end

  describe "Basic Class Tests" do
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
end