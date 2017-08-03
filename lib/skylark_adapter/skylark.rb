module SkylarkAdapter
  class Skylark
    include Singleton

    @@private_token = CONFIG['skylark_adapter']&.fetch('private_token', nil) ? CONFIG['skylark_adapter']['private_token'] : ''
    @@base_url = CONFIG['skylark_adapter']&.fetch('base_url', nil) ? CONFIG['skylark_adapter']['base_url'] : ''

    def get_root(options = {})
      get_objects('organizations/root', options)
    end

    def get_children(parent_organization_id, options = {})
      get_objects("organizations/#{parent_organization_id}/children", options)
    end

    def get_members(organization_id, options = {})
      get_objects("organizations/#{organization_id}/members", options)
    end

    def push(users_openids, message, options = {})
      push_params =
        {
          push: {
            openids: users_openids,

            news_entity: {
              title: message[:title],
              description: '',
              url: message[:url],
              picurl: 'http://cdrtvu.qiniudn.com/Fuh9sN9zzfAQMv0CWXb4iIrEyS4Q'
            },

            template_entity: {
              url: message[:url],

              data: {
                first: {
                  value: message[:title],
                  color: '#173177'
                },
                keyword1: {
                  value: 'Canna',
                  color: '#173177'
                },
                keyword2: {
                  value: Time.now.localtime.strftime("%m月%d日 %H:%M"),
                  color: '#173177'
                },
                remark: {
                  value: message[:supplement],
                  color: '#173177'
                }
              }
            }
          }
        }

      post("#{@@base_url}/pushes", push_params)
    end

    private
    
    def get(url, params = {}, &block)
      response = HTTP.headers('PRIVATE-TOKEN' => @@private_token).get(url, params: params)

      if block_given?
        yield(response.code, response.headers, response.body)
      else
        response
      end
    end

    def post(url, json = {}, &block)
      response = HTTP.headers('PRIVATE-TOKEN' => @@private_token).post(url, json: json)

      if block_given?
        yield(response.code, response.headers, response.body)
      else
        response
      end
    end

    def get_object(resource, uid, params = {})
      get("#{@@base_url}/#{resource}/#{uid}", params) do |code, headers, body|
        JSON.parse(body.to_s)
      end
    end

    def get_objects(resource, params = {})
      if params[:page]
        get("#{@@base_url}/#{resource}", params) do |code, headers, body|
          wrap_objects_in_paginated_array(headers, body)
        end
      else
        get_all_objects(resource, params)
      end
    end

    def get_all_objects(resource, params = {})
      current_page = 1
      total_page = 1
      results = []

      params[:per_page] = 25

      begin
        params[:page] = current_page

        get("#{@@base_url}/#{resource}", params) do |code, headers, body|
          total_page = headers['X-SLP-Total-Pages'].to_i
          results.concat JSON.parse(body.to_s)
        end

        current_page += 1
      end while current_page <= total_page

      results
    end

    def wrap_objects_in_paginated_array(headers, body)
      result = SimpleDelegator.new(JSON.parse(body.to_s))

      result.instance_variable_set(:@current_page, headers['X-SLP-Current-Page'].to_i)
      result.singleton_class.send(:define_method, :current_page) do
        @current_page
      end

      result.instance_variable_set(:@total_page, headers['X-SLP-Total-Pages'].to_i)
      result.singleton_class.send(:define_method, :total_page) do
        @total_page
      end

      result
    end
  end
end
