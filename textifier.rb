# encoding: UTF-8

# converts PDFs to plaintext via docsplit

require 'docsplit'
require 'fileutils'

class Textifier
  def initialize; end

  def textify
    folders = Dir["pdfs/*"]
    folders.each do |folder|
      files = Dir.glob("#{folder}/*")
      files.each do |file|
        FileUtils.mv(file, file + ".pdf") unless file[-4..-1] == ".pdf"
      end
      files = Dir.glob("#{folder}/*")
      files.each do |file|
        outputFilename = file.gsub(".pdf", "")
        outputFilename = outputFilename.gsub("pdf", "txt")

        puts outputFilename + " starting..."
        Docsplit.extract_text([file], :pages => "all", :ocr => false, :output => "#{outputFilename}")
        puts outputFilename + " done!"
      end
    end
  end
end