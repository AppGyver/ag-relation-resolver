module.exports = (angular) ->

  RelationResolver = angular.module "RelationResolver", []
  RelationResolver.service "Relation", require('./RelationResolver')

  RelationResolver.directive "fieldUser", ->
    {
      scope:
        userId: "="
      controller: ($scope, Relation) ->
        $scope.value = Relation.getUserDisplayValue($scope.userId)
      template: """
        <span ng-bind="value"></span>
      """
    }

  RelationResolver.directive "fieldRelation", ->
    {
      scope:
        data: "="
        schema: "="
      controller: ($scope, Relation) ->
        $scope.value = Relation.getRelationDisplayValue($scope.schema, $scope.data)
      template: """
        <span ng-bind="value"></span>
      """
    }

  RelationResolver.directive "fieldMultiRelation", ->
    {
      scope:
        data: "="
        schema: "="
      controller: ($scope, Relation) ->
        $scope.value = Relation.getMultiRelationDisplayValue $scope.schema, $scope.data
      template: """
        <span ng-bind="value">
        </span>
      """
    }

  "RelationResolver"
