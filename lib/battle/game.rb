module Battle
  class Game
    attr_reader :name, :email, :id, :coords, :status, :ships, :prize,
      :response, :nuke_status, :sunk

    STATUSES = %w[start victory defeat]

    def initialize(name = nil, email = nil, id: nil)
      @name = name
      @email = email
      @id = id
      @coords = [nil, nil]
      @status = id ? 'start': 'init'
      @ships = []
      @response = {}
      Battle.ships.each { |name| @ships << Ship.new(name) }
    end

    def register!
      raise PlayerNameNotSpecified if name.nil? || name.empty?
      raise PlayerEmailNotSpecified if email.nil? || email.empty?

      do_request REGISTER_URL, "name" => name, "email" => email
      handle_register

      response
    end

    def nuke(x, y)
      raise GameNotStartedYetError if init?
      raise GameAlreadyFinishedError if finished?

      do_request NUKE_URL, id: id, x: x, y: y
      handle_nuke

      response
    end

    def init?
      status == "init"
    end

    def finished?
      status == "lost" || status == "victory"
    end

    private
    STATUSES.each do |status|
      define_method status do
        @status = status
      end
    end

    def do_request(url, data)
      options = { content_type: :json, accept: :json }
      @response = JSON.parse RestClient.post(url, data.to_json, options)
    end

    def sink_ship(name)
      @sunk = name
      return if name.nil?
      ships.delete ships.find { |ship| ship.is? name }
    end

    def has_ships?
      !ships.empty?
    end

    def won?
      !response["prize"].nil? || !has_ships?
    end

    def handle_nuke
      sink_ship response['sunk']
      handle_nuke_status
      handle_defeat
      handle_victory
      assign_coordinates
    end

    def handle_victory
      if won?
        victory
        @prize = response['prize']
      end
    end

    def handle_nuke_status
      @nuke_status = response['status']
    end

    def handle_defeat
      defeat if response["game_status"] == "lost"
    end

    def handle_register
      @id = response["id"]
      assign_coordinates
      start
    end

    def assign_coordinates
      @coords = [response["x"], response["y"]]
    end
  end
end
