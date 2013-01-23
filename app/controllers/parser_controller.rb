class ParserController < ActionController::Base
  
  def index
  end

  def upload
    uploaded_pdf = params[:pdf]
    full_path = Rails.root.join('public', 'uploads', uploaded_pdf.original_filename)
    File.open(full_path, 'wb') do |file|
      file.write(uploaded_pdf.read)
    end

    output = `pdftotext -raw #{full_path} /dev/stdout`

    File.delete full_path

    @duties = parse output

    render 'index'
  end

  def parse (string)

    duties = []
    string.match(/Period:(.*)(\d\d)(\w\w\w)(\d\d)(.*)(\d\d)(\w\w\w)(\d\d)/)

    months = { 'Jan' => 1, 'Fev' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6, 
     'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12 }
    day = $2.to_i
    month = months[$3]
    year = $4.to_i + 2000
    date = DateTime.new.change( day: day, month: month, year: year) - 1.day


    lines = string.split("\n")

    parsing_flights = false

    lines.each do |line|

      if line.match(/^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\d\d/)
        date = date + 1.day
      end

      if parsing_flights

          if line.match(/(\w\w\w)\s*(!?)(\d\d)(\d\d)\s*(!?)(\d\d)(\d\d)\s*(\w\w\w)\s*(\w*)/i)
            # G3 1935 BSB 1713 !1750 CGB B738
            # G3 1935 (BSB) ()(17)(13) (!)(17)(50) (CGB) (B738)
            duties.push Duty.new(type: 'Flight', 
             from: $1, to: $8,
             start_time: date.change(hour: $3.to_i, min: $4.to_i),
             end_time: date.change(hour: $6.to_i, min: $7.to_i),
             aircraft: $9)

          elsif line.match(/C\/O\s*(!?)(\d\d)(\d\d)\s*(\w\w\w)/i)
            # C/O !1235 MAO
            # C/O (!)(12)(35) (MAO)
            duties.push Duty.new(type: 'Check out', 
             from: $4, to: $4,
             start_time: date.change(hour: $2.to_i, min: $3.to_i),
             end_time: date.change(hour: $2.to_i, min: $3.to_i))

            parsing_flights = false
          end

      elsif line.match(/(\w\w\w)(\d\d)\s*C\/I\s*(\w\w\w)\s*(!?)(\d\d)(\d\d)/i)
        # Thu10 C/I GRU 0910
        # (Thu)(10) C/I (GRU) (09)(10)
        duties.push Duty.new(type: 'Check in', 
                 from: $3, to: $3,
                 start_time: date.change(hour: $5.to_i, min: $6.to_i),
                 end_time: date.change(hour: $5.to_i, min: $6.to_i))

        parsing_flights = true

      elsif line.match(/(\w\w\w)(\d\d)\s*FR\s*(\w\w\w)\s*(\d\d)(\d\d)\s*(\d\d)(\d\d)/i)
        # Sun06 FR SAO 0705 0705
        # (Sun)(06) FR (SAO) (07)(05) (07)(05)
        duties.push Duty.new(type: 'Off', 
                 from: $3, to: $3,
                 start_time: date.change(hour: $4.to_i, min: $5.to_i),
                 end_time: date.change(hour: $6.to_i, min: $7.to_i))

      elsif line.match(/(\w\w\w)(\d\d)\s*([\w-]+)\s*(\w?)\s*(\w\w\w)\s*(!?)(\d\d)(\d\d)\s*(!?)(\d\d)(\d\d)/i)
        # Mon07 C-ENS-EQP R CGH 0815 1745
        # (Mon)(07) (C-ENS-EQP) (R) (CGH) (08)(15) (17)(45)
        duties.push Duty.new(type: $3, 
                 from: $5, to: $5,
                 start_time: date.change(hour: $7.to_i, min: $8.to_i),
                 end_time: date.change(hour: $10.to_i, min: $11.to_i))
      end
    end
    duties
  end
end
