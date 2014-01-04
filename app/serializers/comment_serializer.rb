class CommentSerializer < ActiveModel::Serializer
  attributes :id, :email, :body, :post_id
end
