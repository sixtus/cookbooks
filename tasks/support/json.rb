def parse_json(input)
  JSON.parse(input.force_encoding('utf-8'), create_additions: false).symbolize_keys
end
