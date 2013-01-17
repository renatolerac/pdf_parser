class ParserController < ActionController::Base
  
  def index 
    @output
  end

  def upload
    uploaded_pdf = params[:pdf]
    full_path = Rails.root.join('public', 'uploads', uploaded_pdf.original_filename)
    File.open(full_path, 'wb') do |file|
      file.write(uploaded_pdf.read)
    end

    output = `pdftotext -raw #{full_path} /dev/stdout`
    
    @output = output.html_safe

    File.delete full_path

    @output = parse @output

    render 'index'
  end

    DAYS_SPLIT = /(Sun|Mon|Tue|Wed|Thu|Fri|Sat)(\d{2})(.*?)(?=(Sun|Mon|Tue|Wed|Thu|Fri|Sat|\Z))/

  def parse (string)
    final_strings = []
    string.gsub(/\n+/, "").scan(DAYS_SPLIT) do |m|
      split = ""
      split.concat $1
      split.concat $2
      split.concat $3
      final_strings.push split
    end
    final_strings
  end
end
