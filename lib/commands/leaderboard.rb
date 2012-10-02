class Leaderboard < Flower::Command
  listen_to //i
  respond_to "leaderboard"

  FILE_NAME = "leaderboard.yml"

  class << self
    attr_accessor :stats, :num_messages_logged
  end

  def self.description
    "Show chat leaderboard"
  end

  def self.respond(command, message, sender, flower)
    stats_string = []
    stats.sort_by{ |key, value| value }.reverse.each_with_index do |(nick, stats), index|
      stats_string << "(#{index + 1}) #{nick}: #{stats}"
     end
    flower.paste(stats_string)
  end

  def self.listen(message, sender, flower)
    register_message(sender[:nick])
  end

  private

  def self.register_message(nick)
    stats[nick] ||= 0
    stats[nick] += 1
    self.num_messages_logged += 1
    if num_messages_logged % 100 == 0
      File.write(FILE_NAME, stats.to_yaml)
    end
  end

  def self.init_chat_stats
    self.num_messages_logged = 0
    if parsed = YAML.load_file(FILE_NAME) rescue nil
      self.stats = parsed
    else
      File.write(FILE_NAME, {}.to_yaml)
      self.stats = {}
    end
  end

  init_chat_stats
end