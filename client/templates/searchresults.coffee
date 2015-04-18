Template.searchResults.helpers searchResults: ->
  SearchResults.find {}
Template.searchResults.events
  'click #save': (e) ->
    $('.chk-search').each ->
      if @checked
        id = $(this).attr('data')
        found = StoredResults.findOne(
          userId: Meteor.userId()
          pid: id)
        if !found
          obj = SearchResults.findOne(pid: id)
          if obj
            StoredResults.insert obj
        $(this).attr 'checked', false
      return
    return
  'click #exports': (e) ->
    selected = []
    $('.chk-search').each ->
      if @checked
        id = $(this).attr('data')
        selected.push id
      $(this).attr 'checked', false
      return
    if selected.length == 0
      $('#model_select').modal 'show'
      return
    Meteor.call 'downloadCSVFile', selected, false, (err, fileUrl) ->
      link = document.createElement('a')
      link.download = 'Search Results.csv'
      link.href = fileUrl
      link.click()
      return
    return
  'click #exporta': (e) ->
    Meteor.call 'downloadCSVFile', null, false, (err, fileUrl) ->
      link = document.createElement('a')
      link.download = 'Search Results.csv'
      link.href = fileUrl
      link.click()
      return
    return
