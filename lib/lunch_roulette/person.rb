class LunchRoulette
  class Person
    attr_accessor :name, :lunchable, :previous_lunches, :features, :team, :floor, :user_id, :start_date, :email
    def initialize(hash)
      @features = {}
      @lunchable = %w(true TRUE).include? hash['lunchable']
      @team = hash['team']
      @user_id = hash['user_id']
      @email = hash['email']
      @floor = hash['floor'] # implicitly includes building
      @start_date = hash['start_date']
      @features['days_here'] = [1, (Date.today - Date.strptime(@start_date, '%m/%d/%Y')).to_i].max
      @features['team'] = config.team_mappings[@team].to_i
      @features['floor'] = config.floor_mappings[@team].to_i
      @name = hash['name']
      init_previous_lunches(hash['previous_lunches'])
    end

    def init_previous_lunches(previous_lunches)
      @previous_lunches = []
      if previous_lunches
        config.maxes['lunch_id'] ||= 0
        # list of all previously attended lunches; used to prevent repeats
        @previous_lunches = previous_lunches.split(',').compact.map{|s|s.to_i}
        if @previous_lunches.any? && (@previous_lunches.max > config.maxes['lunch_id'])
          config.maxes['lunch_id'] = @previous_lunches.max
        end
        # Generate previous lunches to person mappings:
        @previous_lunches.map do |previous_lunch|
          config.previous_lunches[previous_lunch] ||= LunchGroup.new
          config.previous_lunches[previous_lunch].people = [config.previous_lunches[previous_lunch].people, self].flatten
        end
      end
    end

    def inspect
      "#{@name} (#{@team})"
    end

    def config
      LunchRoulette::Config
    end

  end
end
