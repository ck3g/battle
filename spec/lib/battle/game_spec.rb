require 'battle'
require 'webmock/rspec'

describe Battle::Game do
  def load_fixture(name)
    File.open File.join("spec", "fixtures", "#{name}.json")
  end

  let(:game) { Battle::Game.new("Bob", "bob@example.com") }
  let(:headers) do
    { 'Accept'=>'application/json', 'Content-Type'=>'application/json' }
  end
  let(:register_response_body) { load_fixture "register" }

  subject { game }
  its(:name) { should eq 'Bob' }
  its(:email) { should eq 'bob@example.com' }
  its(:status) { should eq 'init' }

  it 'stores the ships' do
    expect(game.ships.count).to eq 7
  end

  context 'when init game with remote id' do
    subject { Battle::Game.new id: 503 }
    its(:status) { should eq 'start' }
  end

  describe "#register!" do

    context "when success" do
      before do
        body = "{\"name\":\"Bob\",\"email\":\"bob@example.com\"}"
        stub_request(:post, "http://battle.platform45.com/register").
          with(body: body, headers: headers).
          to_return(status: 200, body: register_response_body, headers: {})
      end

      it "returns game id and coordinates" do
        expect(game.register!).to eq({ "id" => "2746", "x" => 7, "y" => 6 })
      end

      it "stores game id" do
        expect { game.register! }.to change { game.id }.to "2746"
      end

      it "sets last nuke coordinates" do
        expect { game.register! }.to change { game.coords }.to [7, 6]
      end

      it "begins the game" do
        expect { game.register! }.to change { game.status }.to "start"
      end
    end

    context "when name not specified" do
      let(:game) { Battle::Game.new("", "bob@example.com") }
      before do
        body = "{\"name\":\"\",\"email\":\"bob@example.com\"}"
        stub_request(:post, "http://battle.platform45.com/register").
          with(body: body, headers: headers).
          to_return(status: 400, body: register_response_body, headers: {})
      end

      it "raises the exception" do
        expect { game.register! }.to raise_error Battle::PlayerNameNotSpecified
      end
    end

    context "when email not specified" do
      let(:game) { Battle::Game.new("Bob", "") }
      before do
        body = "{\"name\":\"Bob\",\"email\":\"\"}"
        stub_request(:post, "http://battle.platform45.com/register").
          with(body: body, headers: headers).
          to_return(status: 400, body: register_response_body, headers: {})
      end

      it "raises the exception" do
        expect { game.register! }.to raise_error Battle::PlayerEmailNotSpecified
      end
    end
  end

  describe '#nuke' do
    before do
      body = "{\"name\":\"Bob\",\"email\":\"bob@example.com\"}"
      stub_request(:post, "http://battle.platform45.com/register").
        with(body: body, headers: headers).
        to_return(status: 200, body: register_response_body, headers: {})
      game.register!
    end

    it 'changes last coordinates' do
      body = "{\"id\":\"2746\",\"x\":5,\"y\":9}"
      stub_request(:post, "http://battle.platform45.com/nuke").
        with(body: body, headers: headers).
        to_return(status: 200, body: load_fixture("nuke_miss"), headers: {})

      expect { game.nuke(5, 9) }.to change { game.coords }.to [0, 6]
    end

    context 'when miss' do
      before do
        body = "{\"id\":\"2746\",\"x\":5,\"y\":9}"
        stub_request(:post, "http://battle.platform45.com/nuke").
          with(body: body, headers: headers).
          to_return(status: 200, body: load_fixture("nuke_miss"), headers: {})
      end

      it 'launch the salvos' do
        expect(game.nuke(5, 9)).to eq({ 'status' => 'miss', 'x' => 0, 'y' => 6 })
      end

      it "don't change game status" do
        expect { game.nuke(5, 9) }.to_not change { game.status }
      end

      it 'sets nuke_status to miss' do
        game.nuke(5, 9)
        expect(game.nuke_status).to eq 'miss'
      end
    end

    context "when hit battleship" do
      before do
        body = "{\"id\":\"2746\",\"x\":5,\"y\":9}"
        stub_request(:post, "http://battle.platform45.com/nuke").
          with(body: body, headers: headers).
          to_return(status: 200, body: load_fixture("nuke_hit_battleship"), headers: {})
      end

      it 'gets proper response' do
        expect(game.nuke(5, 9)).to eq({ "status" => "hit",
                                        "sunk" => "Battleship",
                                        "x" => 1,
                                        "y" => 7 })
      end

      it 'sets nuke_status to hit' do
        game.nuke(5, 9)
        expect(game.nuke_status).to eq 'hit'
      end

      it 'decrease ships count' do
        expect { game.nuke(5, 9) }.to change { game.ships.count }.by(-1)
      end

      context 'when has ships on battlefield' do
        it "don't change game status" do
          expect { game.nuke(5, 9) }.to_not change { game.status }
        end
      end

      context 'when it was last ship' do
        before { game.stub(:has_ships?).and_return false }
        it 'changes game status' do
          expect { game.nuke(5, 9) }.to change { game.status }.to "victory"
        end
      end
    end

    context "when loose" do
      before do
        body = "{\"id\":\"2746\",\"x\":5,\"y\":9}"
        stub_request(:post, "http://battle.platform45.com/nuke").
          with(body: body, headers: headers).
          to_return(status: 200, body: load_fixture("loose"), headers: {})
      end

      it "changes game status" do
        expect { game.nuke(5, 9) }.to change { game.status }.to 'defeat'
      end
    end

    context "when reach error" do
      before do
        body = "{\"id\":\"2746\",\"x\":5,\"y\":9}"
        stub_request(:post, "http://battle.platform45.com/nuke").
          with(body: body, headers: headers).
          to_return(status: 200, body: load_fixture("error"), headers: {})
      end

      it "returns error message" do
        expect(game.nuke(5, 9)).to eq({ "error" => "something went wrong" })
      end
    end

    context "when grab the prize" do
      before do
        body = "{\"id\":\"2746\",\"x\":5,\"y\":9}"
        stub_request(:post, "http://battle.platform45.com/nuke").
          with(body: body, headers: headers).
          to_return(status: 200, body: load_fixture("grab_the_prize"), headers: {})
      end

      it "changes the game status" do
        expect { game.nuke(5, 9) }.to change { game.status }.to "victory"
      end

      it 'changes game prize' do
        expect {
          game.nuke(5, 9)
        }.to change { game.prize }.to "You've got the prize!"
      end
    end

    context "when game not started" do
      before do
        game.stub(:status).and_return "init"
      end
      it "raises GameNotStartedYetError" do
        expect { game.nuke(1, 2) }.to raise_error Battle::GameNotStartedYetError
      end
    end

    context "when game finished" do
      before do
        game.should_receive(:finished?).and_return true
      end
      it "raises GameAlreadyFinishedError" do
        expect { game.nuke(1, 2) }.to raise_error Battle::GameAlreadyFinishedError
      end
    end
  end

  describe "#finished?" do
    context "when status is init" do
      before { game.stub(:status).and_return "init" }
      it { expect(game.finished?).to be_false }
    end

    context "when status is lost" do
      before { game.stub(:status).and_return "lost" }
      it { expect(game.finished?).to be_true }
    end

    context "when status is victory" do
      before { game.stub(:status).and_return "victory" }
      it { expect(game.finished?).to be_true }
    end
  end
end
