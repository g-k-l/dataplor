class ApplicationController < ActionController::API

  def common_ancestor
    permitted = params.require([:a, :b])
    render json: Node.common_ancestor_data(permitted[0].to_i, permitted[1].to_i)
  end
end
