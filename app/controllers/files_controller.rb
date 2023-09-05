require 'faraday'
require 'json'
require 'csv'
require 'csv_json_converter'

class FilesController < ApplicationController
  


  @options = {
    headers: {
      'Authorization' => 'Bearer aSuperSecretKey'
    }
  }

  @@files = []
  @@file_list = []

  def get_files_list
    conn = Faraday.new(url: 'https://echo-serv.tbxnet.com') do |faraday|
      faraday.adapter Faraday.default_adapter
    end
    
    response = conn.get('/v1/secret/files') do |request|
      request.headers['Authorization'] = 'Bearer aSuperSecretKey'
    end
    

    file_list = []

    if response.status == 200
      data = JSON.parse(response.body)

      file_list = data['files']
    end

    file_list
  end

  def get_all_files(files)
    conn = Faraday.new(url: 'https://echo-serv.tbxnet.com') do |faraday|
      faraday.adapter Faraday.default_adapter
    end

    files.each do |file|
      response = conn.get("/v1/secret/file/#{file}") do |request|
        request.headers['Authorization'] = 'Bearer aSuperSecretKey'
      end


      if response.status == 200
        data = response.body
        
        arr_to_json = CsvJsonConverter.to_json(data)
        
        arr=JSON.parse(arr_to_json)
        arr.each do |row|
          if row[:number] && !/^[0-9]*$/.match?(row[:number])
            row.delete(:number)
          end

          if row[:hex] && !/[0-9A-Fa-f]/.match?(row[:hex])
            row.delete(:hex)
          end
        end

        @@files << arr
      end
    end
  end

  # Example usage:


  def index
    @@file_list = get_files_list()
    get_all_files(@@file_list)
    f=@@files

    render :json => f
    
  end
end
