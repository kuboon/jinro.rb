RSpec.describe "Village" do
  describe "as_json_by player" do
    it do
      players = 3.times.map { Jinro::Player.new }
      v = Villager.new(players, wolf: 1, seer: 1, villager: 2)
      seer = v.players.grep(:seer)[0]
      v0, v1 = v.players.grep(:villager)
      v.action!
      json = v.as_json_by(v0)
      expect(json.actions).not_to include(
        type: :see
      )
    end
  end
end
