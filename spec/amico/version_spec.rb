require 'spec_helper'

describe 'Amico::VERSION' do
  it 'should be the correct version' do
    expect(Amico::VERSION).to eq('2.3.2')
  end
end