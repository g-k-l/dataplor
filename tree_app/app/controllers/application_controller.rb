class ApplicationController < ActionController::API

  def common_ancestor
    permitted = params.require([:a, :b])
    render json: Node.common_ancestor_data(permitted[0].to_i, permitted[1].to_i)
  end

  def birds
    permitted = params.require(:ids).map { |param| param.to_i }
    render json: Bird.where(nodes_id: Node.descendants_of(permitted) + permitted)
  end
end
