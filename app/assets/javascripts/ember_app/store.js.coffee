# http://emberjs.com/guides/models/defining-a-store/
# uncomment the following to add a namespace to the requests
#DS.RESTAdapter.reopen
#  namespace: 'api'

App.ApplicationSerializer = DS.ActiveModelSerializer
App.Store = DS.Store.extend
  adapter: DS.RESTAdapter
