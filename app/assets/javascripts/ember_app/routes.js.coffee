App.Router.reopen
  location: 'history'

App.Router.map ->
  @resource 'posts', ->
    @resource 'post', path: ':post_id', ->
      @resource 'comments', ->
        @resource 'comment', path: ':comment_id'

