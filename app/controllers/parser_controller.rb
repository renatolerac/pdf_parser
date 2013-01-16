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

    @output = `pdftotext -raw #{Rails.root.join('public', 'uploads', uploaded_pdf.original_filename)} /dev/stdout`
    
    File.delete full_path

    render 'parser/index'
  end
end
