App.IndexRoute = Ember.Route.extend
  model: (params, queryParams)->
    Ember.Object.create
      posts: @store.find 'post'
  #setupController: (controller, model)->
    #controller.set('model', model)

