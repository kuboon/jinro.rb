RSpec.describe Jinro do
  it "has a version number" do
    expect(Jinro::VERSION).not_to be nil
  end

  it "creates new village" do
    v = Jinro::Village.new(wolf: 1, seer: 1, villager: 3)
    json = v.as_json
    v2 = Jinro::Village.from_json(json)
    expect(json).to eq(vs.as_json)
    expect(json).to eq(
      players: [
        {
          name: "hoge",
          type: "villager",
          died_on: nil,
          died_of: nil
        }
      ],
      days: [
        {
          survivors: [0,1,2]
        },
        {
          survivors: [0,1,2],
          lynched: 1,
          victims: [0]
        }
      ],
      actions: [
        {
          day: 0,
          actor: 1,
          target: 0,
          type: "see",
        },
        {
          day: 1,
          actor: 0,
          target: 1,
          type: "vote"
        }
      ],
      notifs: [
        {
          type: "see",
          receiver: 1,
          result: "black"
        }
      ]
    )
  end

  it "accepts actions and votes" do
    players = 5.times.map{ Jinro::Player.new }
    players[0].name = "村人1"
    players[0].wish = :villager

    v = Jinro::Village.new(players, wolf:1, seer:1, villager: 3)
    v.today.action! # skip day 0
    wolf = v.players.grep(:wolf)[0]
    v1, v2, v3 = v.players.grep(:villager)
    seer = v.players.grep(:seer)[0]

    wolf.set_action(bite: v1, vote: v2)
    v1.set_action(vote: v2.id) # both ok
    seer.set_action(see: wolf)
    day1 = v.today
    v.action!
    expect(v.yesterday).to eq day1
    expect(day1.victims[0]).to eq v1.id
    expect(v1.died_on).to eq day1.id
    expect(v1.died_of).to eq "bite"
    
    expect(day1.lynched).to eq v2
    expect(v2.died_of).to eq "lynch"

    expect(day1.actions.find{|id, a| a.is_a? :see}[1].result).to eq "black"

    expect(day1.to_s).to include "村人1は処刑された"

    expect(v.over?).to eq false
    expect(v.today.survivors.count).to eq 3
end
