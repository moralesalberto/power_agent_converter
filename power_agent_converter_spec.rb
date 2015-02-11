require_relative 'power_agent_converter'

describe PowerAgentConverter do
  let(:filename) { 'workout.csv' }

  let(:converter) { PowerAgentConverter.new(filename) }

  it 'reads the excel file' do
    expect(converter.filename).to eq(filename)
  end

  it 'finds the rows' do
    expect(converter.rows.size).to eq(37)
  end

  context 'one row' do
    let(:row) { converter.rows.last }

    it 'can read the duration units' do
      expect(row.duration_units).to eq('3:01')
    end

    it 'reads the minutes' do
      expect(row.minutes).to eq(3)
    end

    it 'reads the seconds' do
      expect(row.seconds).to eq(1)
    end

    it 'calculates duration in seconds' do
      expect(row.duration).to eq(181)
    end
  end
end
