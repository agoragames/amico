require 'spec_helper'

describe Amico::Configuration do
  describe '#configure' do
    it 'should have default attributes' do
      Amico.configure do |configuration|
        expect(configuration.namespace).to eql('amico')
        expect(configuration.following_key).to eql('following')
        expect(configuration.followers_key).to eql('followers')
        expect(configuration.blocked_key).to eql('blocked')
        expect(configuration.blocked_by_key).to eql('blocked_by')
        expect(configuration.reciprocated_key).to eql('reciprocated')
        expect(configuration.pending_key).to eql('pending')
        expect(configuration.pending_with_key).to eql('pending_with')
        expect(configuration.default_scope_key).to eql('default')
        expect(configuration.pending_follow).to be_falsey
        expect(configuration.page_size).to be(25)
      end
    end
  end
end