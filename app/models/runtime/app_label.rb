module VCAP::CloudController
  class AppLabel < Sequel::Model(:app_labels)
    # one_to_one :app_guid, class: 'VCAP::CloudController::AppModel', key: :guid, primary_key: :app_guid

    def validate
      validates_presence :app_guid
      validates_presence :label_key
      #validates_format /\A([\w\-]+|\*)\z/, :label_key
      #validates_format /\A([\w\-]+|\*)\z/, :label_value if label_value
    end

    def self.select_by_og(label_selector)
      label_key, label_value  = label_selector.split(/\s*,\s*/).first.split(/\s*==?\s*/)
      self.select(:app_guid).where(label_key: label_key, label_value: label_value).map(&:app_guid)
    end
    # [env: {production}, tier:{}]
    def self.select_by(label_selector)
      and_parts = label_selector.split(/\s*,\s*/)
      dataset = self.evaluate_and_parts(and_parts)
      dataset.map(&:app_guid)
    end

    def self.evaluate_equal(label_key, label_value)
      self.select(:app_guid).where(label_key: label_key, label_value: label_value)
    end

    def self.evaluate_not_equal(label_key, label_value)
      # self.except(self.evaluate_equal(label_key, label_value)).all
      self.select(:app_guid).except(self.select(:app_guid).where(label_key: label_key, label_value: label_value))
    end

    def self.evaluate_in_set(part)
    end

    def self.evaluate_not_in_set(part)
    end

    def self.evaluate_and_parts(parts)
      name_re = /\w[-\w\._\/]*\w?/
      table = [
        { ptn: /(#{name_re})\s*==?\s*(.*)/, method: :evaluate_equal},
        { ptn: /(#{name_re})\s*!=\s*(.*)/, method: :evaluate_not_equal},
        { ptn: /(#{name_re})\s* in \s*\((.*)\)$/, method: :evaluate_in_set}, # This doesn't work!
        { ptn: /(#{name_re})\s* notin \s*\((.*)\)$/, method: :evaluate_not_in_set}, # This doesn't work either
      ]
      parts.inject(nil) {| dataset, current_part |
        our_match = nil
        entry = table.find{|t| our_match = t[:ptn].match(current_part)}
        if !entry
          raise StandardError.new("awp you fool")
        end
        ds = self.send(entry[:method], our_match[1], our_match[2])
        if dataset.nil?
          ds
        else
          dataset.intersect(ds)
        end
      }
    end

    def self.parse(input)
      tokens = tokenizer(input)
      parts = []
      in_set = false
      tokens.each do |token|


      end

    end

    def self.tokenizer(input)
      token_pairs = input.scan(/(\w+|==|!=|[,\(\)=])|(.)/)
      if token_pairs.any? {|pair| pair.last}
        raise StandardError.new("Error in label_selector")
      end
      token_pairs.map(&:first)
    end
  end
end
