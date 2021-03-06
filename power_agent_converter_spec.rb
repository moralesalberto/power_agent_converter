require_relative 'power_agent_converter'

describe HtmlParser do
  let(:filename) { 'input.html'}
  let(:html_parser) { HtmlParser.new(filename) }

  it 'should read the doc from the html and find the html tables' do
    expect(html_parser.html_tables.size).to eq(7)
  end

  it 'should find the data table' do
    expect(html_parser.data_table.to_s).to include("tableSmall")
  end

  it 'should find the html rows' do
    expect(html_parser.html_rows.size).to eq(74)
  end

  it 'should find the data rows' do
    expect(html_parser.data_rows.size).to eq(72) #remove header and footer
  end


end

describe PowerAgentConverter do
  let(:filename) { 'input.html' }

  let(:converter) { PowerAgentConverter.new(filename, 1.0) }

  it 'reads the html file' do
    expect(converter.filename).to eq(filename)
  end

  it 'finds the rows' do
    expect(converter.rows.size).to eq(72)
  end

  it 'should make sure all rows have the same type of cells' do
    expect(converter.rows.all? { |row| row.cells.size == 25 or row.cells.size == 24 or row.cells.size == 27 }).to be_truthy
  end

  context 'one row' do
    let(:row) { converter.rows.last }

    it 'can read the duration units' do
      expect(row.duration_units).to eq('00:04')
    end

    it 'reads the minutes' do
      expect(row.minutes).to eq(0)
    end

    it 'reads the seconds' do
      expect(row.seconds).to eq(4)
    end

    it 'calculates duration in seconds' do
      expect(row.duration).to eq(4)
    end

    it 'reads the power' do
      expect(row.target_power).to eq(94)
    end
  end

  context 'another row' do
    let(:another_row) { converter.rows[9] }

    it 'can read the duration units' do
      expect(another_row.duration_units).to eq('00:31')
    end

    it 'reads the minutes' do
      expect(another_row.minutes).to eq(0)
    end

    it 'reads the seconds' do
      expect(another_row.seconds).to eq(31)
    end

    it 'calculates duration in seconds' do
      expect(another_row.duration).to eq(31)
    end

    it 'reads the power' do
      expect(another_row.target_power).to eq(235)
    end
  end


  it 'writes the xml file' do
    expect(converter.to_file).to be_nil
  end
end
