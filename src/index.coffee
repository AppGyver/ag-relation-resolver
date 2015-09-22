
module.exports = (angular) ->

  if angular?
    require('./RelationResolverModule')(angular)
  else
    RelationResolver = require('./RelationResolver')
    new RelationResolver
