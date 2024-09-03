require "ood_core/job/adapters/kubernetes/slug_generator"

RSpec.describe SlugGenerator do
  describe '#safe_slug' do
    subject { described_class.safe_slug(input) }

    {
      "preserves valid names" => ["jupyter-alex", "jupyter-alex"],
      "converts uppercase to lowercase" => ["jupyter-Alex", "jupyter-alex"],
      "removes unicode characters" => ["jupyter-üni", "jupyter-ni---a5aaf5dd"],
      "preserves dots in usernames" => ["john.doe", "john.doe"],
      "handles multiple dots" => ["user.name.with.dots", "user.name.with.dots"],
      "removes leading and trailing dots" => [".user.name.", "user.name"],
      "handles mixture of dots and hyphens" => ["user.name-with-hyphens.and.dots", "user.name-with-hyphens.and.dots"],
      "handles long names with dots" => ["very.long.user.name.that.exceeds.the.maximum.length", nil]
    }.each do |description, (input, expected)|
      it description do
        result = subject
        if expected.nil?
          puts "For input '#{input}', the output is: #{result}"
          expect(result).to match(/^very\.long\.user\.name\.that\.exceeds\.the\.maximum\.length---[a-f0-9]{8}$/)
        else
          expect(result).to eq(expected)
        end
      end
    end

    it "ensures slug doesn't end with '-' or '.'" do
      expect(described_class.safe_slug("jupyter-")).not_to end_with('-', '.')
      expect(described_class.safe_slug("jupyter.")).not_to end_with('-', '.')
    end
  end
end
