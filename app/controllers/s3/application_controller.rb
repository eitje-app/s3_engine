module S3
  class ApplicationController < ActionController::API

      private

      def slice_params(*args)
        params.slice(*args).as_json.symbolize_keys
      end

  end
end
