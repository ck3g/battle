require 'battle'

describe Battle do
  describe '.ships' do
    it 'contains proper ships list' do
      expect(Battle.ships).to eq [
        'Carrier',
        'Battleship',
        'Destroyer',
        'Submarine',
        'Submarine',
        'Patrol Boat',
        'Patrol Boat'
      ]
    end
  end
end
