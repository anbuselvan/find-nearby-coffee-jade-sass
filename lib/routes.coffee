Router.configure layoutTemplate: 'layout'
Router.route '/', ->
  @render 'home'
  return
