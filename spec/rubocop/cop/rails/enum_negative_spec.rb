# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnumNegative do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense' do
    expect_offense(<<~RUBY)
          enum status: { active: 1, not_active: 2, semiactive: 3 }
                                    ^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
    RUBY
  end
end
