require 'battle'

describe Battle::Ship do
  let(:battleship) { Battle::Ship.new 'Battleship' }

  it 'stores ship name' do
    expect(battleship.name).to eq 'Battleship'
  end

  describe '#is?' do
    context 'when ask if ship is Battleship' do
      it { expect(battleship.is? 'Battleship').to be_true }
    end

    context 'when ask if ship is Submarine' do
      it { expect(battleship.is? 'Submarine').to be_false }
    end
  end
end
